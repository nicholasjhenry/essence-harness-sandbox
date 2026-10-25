defmodule Shortener.Features.ResolveTargetUrlOfShortUrl.CommandHandlerTest do
  use Shortener.DataCase, async: false

  alias Shortener.DCB.{DecisionModel, Query, QueryItem}
  alias Shortener.EventStore
  alias Shortener.Features.DeleteLinkOfUser.LinkOwner
  alias Shortener.Features.ResolveTargetUrlOfShortUrl.CommandHandler
  alias Shortener.Projections.LinkOfShortCode
  alias Shortener.Shared.{EmailAddress, LinkDeleted, LinkShortened, ShortCode, ShortUrlResolved}

  @now ~U[2026-10-25 12:00:00.000000Z]

  defp shorten(short_code, target_url, owner \\ nil) do
    fact = %LinkShortened{
      short_code: short_code,
      target_url: target_url,
      owner_email_address: owner,
      shortened_at: @now
    }

    :ok = EventStore.append(LinkShortened.to_event(fact), nil)
  end

  defp delete(short_code, owner) do
    fact = %LinkDeleted{short_code: short_code, owner_email_address: owner, deleted_at: @now}
    :ok = EventStore.append(LinkDeleted.to_event(fact), nil)
  end

  defp resolutions do
    query = %Query{items: [%QueryItem{types: [ShortUrlResolved.type_name()], tags: []}]}
    EventStore.read(query, [])
  end

  defp resolution_event(short_code, owner) do
    ShortUrlResolved.to_event(%ShortUrlResolved{
      short_code: short_code,
      target_url: "https://example.com/" <> short_code,
      owner_email_address: owner,
      resolved_at: @now
    })
  end

  describe "resolving a short code" do
    test "gives the target URL given a link of a visitor" do
      shorten("Abc1234", "https://example.com/a")

      assert {:ok, %ShortUrlResolved{target_url: "https://example.com/a"}} =
               CommandHandler.handle("Abc1234", @now)
    end

    test "gives the target URL given a link of a user" do
      shorten("Abc1234", "https://example.com/b", "ada@example.com")

      assert {:ok, %ShortUrlResolved{target_url: "https://example.com/b"}} =
               CommandHandler.handle("Abc1234", @now)
    end

    test "gives the target URL of the link of the short code, and of no other link" do
      shorten("Abc1234", "https://example.com/a")
      shorten("Xyz9876", "https://example.com/z")

      assert {:ok, %ShortUrlResolved{target_url: "https://example.com/z"}} =
               CommandHandler.handle("Xyz9876", @now)
    end

    test "gives not found given a short code that no link has" do
      assert CommandHandler.handle("Abc1234", @now) == {:error, :not_found}
    end

    test "gives not found given a deleted link" do
      shorten("Abc1234", "https://example.com/a", "ada@example.com")
      delete("Abc1234", "ada@example.com")

      assert CommandHandler.handle("Abc1234", @now) == {:error, :not_found}
    end

    test "gives not found given a value that is not a short code" do
      assert CommandHandler.handle("plans", @now) == {:error, :not_found}
      assert CommandHandler.handle("Abc-123", @now) == {:error, :not_found}
    end
  end

  describe "recording a resolution" do
    test "appends one resolution with only the tag of the short code given a link of a visitor" do
      shorten("Abc1234", "https://example.com/a")

      assert {:ok,
              %ShortUrlResolved{
                short_code: "Abc1234",
                target_url: "https://example.com/a",
                owner_email_address: nil,
                resolved_at: @now
              }} = CommandHandler.handle("Abc1234", @now)

      assert [%{event: event}] = resolutions()
      assert event.tags == [ShortCode.tag("Abc1234")]
    end

    test "appends one resolution with the tag of the owner given a link of a user" do
      shorten("Abc1234", "https://example.com/b", "ada@example.com")

      assert {:ok, %ShortUrlResolved{owner_email_address: "ada@example.com"}} =
               CommandHandler.handle("Abc1234", @now)

      assert [%{event: event}] = resolutions()

      assert Enum.sort(event.tags) ==
               Enum.sort([ShortCode.tag("Abc1234"), EmailAddress.tag("ada@example.com")])
    end

    test "appends one resolution for each request given two requests" do
      shorten("Abc1234", "https://example.com/a")

      {:ok, _resolved} = CommandHandler.handle("Abc1234", @now)
      {:ok, _resolved} = CommandHandler.handle("Abc1234", @now)

      assert length(resolutions()) == 2
    end

    test "appends nothing given a short code that no link has" do
      {:error, :not_found} = CommandHandler.handle("Abc1234", @now)

      assert resolutions() == []
    end

    test "appends nothing given a deleted link" do
      shorten("Abc1234", "https://example.com/a", "ada@example.com")
      delete("Abc1234", "ada@example.com")

      {:error, :not_found} = CommandHandler.handle("Abc1234", @now)

      assert resolutions() == []
    end
  end

  describe "broadcasting a resolution" do
    test "broadcasts the resolution on the topic of the owner given a link of the owner" do
      shorten("Abc1234", "https://example.com/a", "ada@example.com")
      Phoenix.PubSub.subscribe(Shortener.PubSub, ShortUrlResolved.topic("ada@example.com"))

      {:ok, _resolved} = CommandHandler.handle("Abc1234", @now)

      assert_received {:short_url_resolved, %ShortUrlResolved{short_code: "Abc1234"}}
    end

    test "broadcasts nothing on the topic of the user given a link of a different user" do
      shorten("Grace12", "https://example.com/g", "grace@example.com")
      Phoenix.PubSub.subscribe(Shortener.PubSub, ShortUrlResolved.topic("ada@example.com"))

      {:ok, _resolved} = CommandHandler.handle("Grace12", @now)

      refute_received {:short_url_resolved, _resolved}
    end

    test "broadcasts nothing given a short code that no link has" do
      Phoenix.PubSub.subscribe(Shortener.PubSub, ShortUrlResolved.topic("ada@example.com"))

      {:error, :not_found} = CommandHandler.handle("Abc1234", @now)

      refute_received {:short_url_resolved, _resolved}
    end
  end

  describe "deciding a resolution under a conflicting event" do
    test "fails the append given a deletion of the same link after the read" do
      shorten("Abc1234", "https://example.com/Abc1234", "ada@example.com")
      {_model, condition} = DecisionModel.build(EventStore, link: LinkOfShortCode.new("Abc1234"))

      delete("Abc1234", "ada@example.com")

      assert {:error, :append_condition_failed} =
               EventStore.append(resolution_event("Abc1234", "ada@example.com"), condition)
    end

    test "keeps the append given a resolution of the same link after the read" do
      shorten("Abc1234", "https://example.com/Abc1234", "ada@example.com")
      {_model, condition} = DecisionModel.build(EventStore, link: LinkOfShortCode.new("Abc1234"))

      {:ok, _resolved} = CommandHandler.handle("Abc1234", @now)

      assert :ok = EventStore.append(resolution_event("Abc1234", "ada@example.com"), condition)
    end

    test "keeps the append of a deletion given a resolution of the same link after the read" do
      shorten("Abc1234", "https://example.com/Abc1234", "ada@example.com")
      {_model, condition} = DecisionModel.build(EventStore, link_owner: LinkOwner.new("Abc1234"))

      {:ok, _resolved} = CommandHandler.handle("Abc1234", @now)

      event =
        LinkDeleted.to_event(%LinkDeleted{
          short_code: "Abc1234",
          owner_email_address: "ada@example.com",
          deleted_at: @now
        })

      assert :ok = EventStore.append(event, condition)
    end
  end
end
