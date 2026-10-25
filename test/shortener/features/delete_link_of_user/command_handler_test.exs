defmodule Shortener.Features.DeleteLinkOfUser.CommandHandlerTest do
  use Shortener.DataCase, async: false

  import Shortener.LoginFixtures

  alias Shortener.DCB.DecisionModel
  alias Shortener.EventStore
  alias Shortener.Features.DeleteLinkOfUser.{CommandHandler, LinkOwner}
  alias Shortener.Features.{EndLoginSessionOfUser, ListLinksOfUser, ShortenTargetUrlForUser}
  alias Shortener.Features.ResolveTargetUrlOfShortUrl
  alias Shortener.Shared.{LinkDeleted, LinkShortened, ShortUrlResolved}

  @now ~U[2026-10-24 12:00:00.000000Z]

  defp shorten(scope, short_code) do
    command =
      %ShortenTargetUrlForUser.Command{}
      |> ShortenTargetUrlForUser.Command.changeset(%{
        "target_url" => "https://example.com/" <> short_code,
        "short_code" => short_code
      })
      |> Ecto.Changeset.apply_action!(:insert)

    ShortenTargetUrlForUser.CommandHandler.handle(scope, command, [short_code], @now)
  end

  defp shorten_for_visitor(short_code) do
    fact = %LinkShortened{
      short_code: short_code,
      target_url: "https://example.com/" <> short_code,
      shortened_at: @now
    }

    :ok = EventStore.append(LinkShortened.to_event(fact), nil)
  end

  defp deletions do
    query = %Shortener.DCB.Query{
      items: [%Shortener.DCB.QueryItem{types: [LinkDeleted.type_name()], tags: []}]
    }

    EventStore.read(query, [])
  end

  describe "deleting the link of a user" do
    test "appends one deletion given a link of the user" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")

      assert {:ok, %LinkDeleted{short_code: "Ada1234", owner_email_address: "ada@example.com"}} =
               CommandHandler.handle(scope, "Ada1234", @now)

      assert [_deletion] = deletions()
    end

    test "returns not found given a short code of no link" do
      scope = login_scope("ada@example.com")

      assert {:error, :not_found} = CommandHandler.handle(scope, "Nolink1", @now)
      assert deletions() == []
    end

    test "returns not found given a link of a different user" do
      {:ok, _link} = shorten(login_scope("grace@example.com"), "Grace12")

      assert {:error, :not_found} =
               CommandHandler.handle(login_scope("ada@example.com"), "Grace12", @now)

      assert deletions() == []
    end

    test "returns not found given a link of a visitor" do
      shorten_for_visitor("Visit12")

      assert {:error, :not_found} =
               CommandHandler.handle(login_scope("ada@example.com"), "Visit12", @now)

      assert deletions() == []
    end

    test "returns not found given a deleted link" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")
      {:ok, _deleted} = CommandHandler.handle(scope, "Ada1234", @now)

      assert {:error, :not_found} = CommandHandler.handle(scope, "Ada1234", @now)
      assert [_deletion] = deletions()
    end

    test "returns not found given a value that is not a short code" do
      scope = login_scope("ada@example.com")

      assert {:error, :not_found} = CommandHandler.handle(scope, "not-a-code", @now)
    end

    test "returns not logged in given an ended login session" do
      session_token = start_login_session("ada@example.com")
      scope = ShortenerWeb.UserAuth.scope_for_session_token(session_token)
      {:ok, _link} = shorten(scope, "Ada1234")
      :ok = EndLoginSessionOfUser.CommandHandler.handle(session_token, @now)

      assert {:error, :not_logged_in} = CommandHandler.handle(scope, "Ada1234", @now)
      assert deletions() == []
    end
  end

  describe "deciding a deletion under a conflicting event" do
    test "fails the append given a deletion of the same link after the read" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")

      {_model, condition} =
        DecisionModel.build(EventStore, link_owner: LinkOwner.new("Ada1234"))

      {:ok, _deleted} = CommandHandler.handle(scope, "Ada1234", @now)

      event =
        LinkDeleted.to_event(%LinkDeleted{
          short_code: "Ada1234",
          owner_email_address: "ada@example.com",
          deleted_at: @now
        })

      assert {:error, :append_condition_failed} = EventStore.append(event, condition)
    end

    test "fails the append given the logout of the login session after the read" do
      session_token = start_login_session("ada@example.com")
      scope = ShortenerWeb.UserAuth.scope_for_session_token(session_token)
      {:ok, _link} = shorten(scope, "Ada1234")

      projections = [
        login_session: Shortener.Projections.LoginSessionUser.new(scope.session_token_hash)
      ]

      {_model, condition} = DecisionModel.build(EventStore, projections)
      :ok = EndLoginSessionOfUser.CommandHandler.handle(session_token, @now)

      event =
        LinkDeleted.to_event(%LinkDeleted{
          short_code: "Ada1234",
          owner_email_address: "ada@example.com",
          deleted_at: @now
        })

      assert {:error, :append_condition_failed} = EventStore.append(event, condition)
    end

    test "fails the append of a shortening given a deletion of the same owner after the read" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")

      {_model, condition} =
        DecisionModel.build(EventStore,
          user_link_count: ShortenTargetUrlForUser.UserLinkCount.new("ada@example.com")
        )

      {:ok, _deleted} = CommandHandler.handle(scope, "Ada1234", @now)

      event =
        LinkShortened.to_event(%LinkShortened{
          short_code: "Ada5678",
          target_url: "https://example.com/Ada5678",
          owner_email_address: "ada@example.com",
          shortened_at: @now
        })

      assert {:error, :append_condition_failed} = EventStore.append(event, condition)
    end
  end

  describe "reading a link after its deletion" do
    setup do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")
      {:ok, _link} = shorten(scope, "Ada5678")
      {:ok, _deleted} = CommandHandler.handle(scope, "Ada1234", @now)
      %{scope: scope}
    end

    test "resolves to not found given a deleted link" do
      assert {:error, :not_found} =
               ResolveTargetUrlOfShortUrl.CommandHandler.handle("Ada1234", @now)

      assert {:ok, %ShortUrlResolved{target_url: "https://example.com/Ada5678"}} =
               ResolveTargetUrlOfShortUrl.CommandHandler.handle("Ada5678", @now)
    end

    test "leaves the deleted link out of the list of the links of the user" do
      assert [%ListLinksOfUser.ListedLink{link: %LinkShortened{short_code: "Ada5678"}}] =
               ListLinksOfUser.LinkList.of("ada@example.com")
    end

    test "counts only the links that exist" do
      assert %ShortenTargetUrlForUser.LinkUsage{link_count: 1} =
               ShortenTargetUrlForUser.LinkUsage.of("ada@example.com")
    end

    test "returns short code taken given a shortening that chooses the short code of a deleted link",
         %{scope: scope} do
      assert {:error, :short_code_taken} = shorten(scope, "Ada1234")
    end
  end

  describe "shortening after a deletion at the link limit" do
    test "shortens a target URL given a user on the Free plan who deleted one of 10 links" do
      scope = login_scope("ada@example.com")
      for n <- 0..9, do: {:ok, _link} = shorten(scope, "Limit0#{n}")

      assert {:error, :link_limit_reached} = shorten(scope, "Limit10")

      {:ok, _deleted} = CommandHandler.handle(scope, "Limit00", @now)

      assert {:ok, %LinkShortened{short_code: "Limit10"}} = shorten(scope, "Limit10")
    end
  end
end
