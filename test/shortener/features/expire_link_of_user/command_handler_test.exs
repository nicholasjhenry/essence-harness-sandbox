defmodule Shortener.Features.ExpireLinkOfUser.CommandHandlerTest do
  use Shortener.DataCase, async: false

  import Shortener.LoginFixtures

  alias Shortener.DCB.{DecisionModel, Query, QueryItem}
  alias Shortener.EventStore
  alias Shortener.Features.ExpireLinkOfUser.{Command, CommandHandler}
  alias Shortener.Features.{DeleteLinkOfUser, EndLoginSessionOfUser, ShortenTargetUrlForUser}
  alias Shortener.Features.ResolveTargetUrlOfShortUrl
  alias Shortener.Projections.{LinkOfShortCode, LoginSessionUser}

  alias Shortener.Shared.{
    LinkDeleted,
    LinkExpirationSet,
    LinkShortened,
    OwnedLink,
    ShortUrlResolved
  }

  @now ~U[2026-10-25 12:00:00.000000Z]
  @later ~U[2026-10-26 12:00:00Z]

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

  defp command(expires_at), do: %Command{expires_at: expires_at}

  defp expirations do
    query = %Query{items: [%QueryItem{types: [LinkExpirationSet.type_name()], tags: []}]}
    EventStore.read(query, [])
  end

  defp expiration_event(short_code, expires_at) do
    LinkExpirationSet.to_event(%LinkExpirationSet{
      short_code: short_code,
      owner_email_address: "ada@example.com",
      expires_at: expires_at,
      set_at: @now
    })
  end

  describe "expiring the link of a user" do
    test "appends one expiration given a link of the user" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")

      assert {:ok,
              %LinkExpirationSet{
                short_code: "Ada1234",
                owner_email_address: "ada@example.com",
                expires_at: @later,
                set_at: @now
              }} = CommandHandler.handle(scope, "Ada1234", command(@later), @now)

      assert [_expiration] = expirations()
    end

    test "replaces the time of expiration given a second expiration before the first time" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")
      {:ok, _set} = CommandHandler.handle(scope, "Ada1234", command(@later), @now)
      earlier = DateTime.add(@now, 3600, :second)

      assert {:ok, _set} = CommandHandler.handle(scope, "Ada1234", command(earlier), @now)
      assert [_first, _second] = expirations()

      assert {:ok, %LinkOfShortCode{expires_at: ^earlier}} =
               OwnedLink.of("ada@example.com", "Ada1234")
    end

    test "returns not found given a short code of no link" do
      scope = login_scope("ada@example.com")

      assert {:error, :not_found} =
               CommandHandler.handle(scope, "Nolink1", command(@later), @now)

      assert expirations() == []
    end

    test "returns not found given a link of a different user" do
      {:ok, _link} = shorten(login_scope("grace@example.com"), "Grace12")
      scope = login_scope("ada@example.com")

      assert {:error, :not_found} =
               CommandHandler.handle(scope, "Grace12", command(@later), @now)

      assert expirations() == []
    end

    test "returns not found given a link of a visitor" do
      shorten_for_visitor("Visit12")
      scope = login_scope("ada@example.com")

      assert {:error, :not_found} =
               CommandHandler.handle(scope, "Visit12", command(@later), @now)

      assert expirations() == []
    end

    test "returns not found given a deleted link" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")
      {:ok, _deleted} = DeleteLinkOfUser.CommandHandler.handle(scope, "Ada1234", @now)

      assert {:error, :not_found} =
               CommandHandler.handle(scope, "Ada1234", command(@later), @now)

      assert expirations() == []
    end

    test "returns not found given a value that is not a short code" do
      scope = login_scope("ada@example.com")

      assert {:error, :not_found} =
               CommandHandler.handle(scope, "not-a-code", command(@later), @now)
    end

    test "returns not after now given a time of expiration that is the time now" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")

      assert {:error, :not_after_now} =
               CommandHandler.handle(scope, "Ada1234", command(@now), @now)

      assert expirations() == []
    end

    test "returns expired given a link whose time of expiration is past" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")
      {:ok, _set} = CommandHandler.handle(scope, "Ada1234", command(@later), @now)
      after_later = DateTime.add(@later, 1, :second)

      assert {:error, :expired} =
               CommandHandler.handle(
                 scope,
                 "Ada1234",
                 command(DateTime.add(@later, 3600, :second)),
                 after_later
               )

      assert [_expiration] = expirations()
    end

    test "returns not logged in given an ended login session" do
      session_token = start_login_session("ada@example.com")
      scope = ShortenerWeb.UserAuth.scope_for_session_token(session_token)
      {:ok, _link} = shorten(scope, "Ada1234")
      :ok = EndLoginSessionOfUser.CommandHandler.handle(session_token, @now)

      assert {:error, :not_logged_in} =
               CommandHandler.handle(scope, "Ada1234", command(@later), @now)

      assert expirations() == []
    end
  end

  describe "reading the link of the owner for the page" do
    test "returns the link with no time of expiration given a link of the user" do
      {:ok, _link} = shorten(login_scope("ada@example.com"), "Ada1234")

      assert {:ok, %LinkOfShortCode{link: %LinkShortened{short_code: "Ada1234"}, expires_at: nil}} =
               OwnedLink.of("ada@example.com", "Ada1234")
    end

    test "returns not found given a link of a different user" do
      {:ok, _link} = shorten(login_scope("grace@example.com"), "Grace12")

      assert {:error, :not_found} = OwnedLink.of("ada@example.com", "Grace12")
    end

    test "returns not found given a deleted link" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")
      {:ok, _deleted} = DeleteLinkOfUser.CommandHandler.handle(scope, "Ada1234", @now)

      assert {:error, :not_found} = OwnedLink.of("ada@example.com", "Ada1234")
    end

    test "returns not found given a value that is not a short code" do
      assert {:error, :not_found} = OwnedLink.of("ada@example.com", "not-a-code")
    end
  end

  describe "deciding an expiration under a conflicting event" do
    setup do
      session_token = start_login_session("ada@example.com")
      scope = ShortenerWeb.UserAuth.scope_for_session_token(session_token)
      {:ok, _link} = shorten(scope, "Ada1234")
      %{scope: scope, session_token: session_token}
    end

    test "fails the append given an expiration of the same link after the read", %{scope: scope} do
      {_model, condition} = DecisionModel.build(EventStore, link: LinkOfShortCode.new("Ada1234"))
      {:ok, _set} = CommandHandler.handle(scope, "Ada1234", command(@later), @now)

      assert {:error, :append_condition_failed} =
               EventStore.append(expiration_event("Ada1234", @later), condition)
    end

    test "fails the append given a deletion of the same link after the read", %{scope: scope} do
      {_model, condition} = DecisionModel.build(EventStore, link: LinkOfShortCode.new("Ada1234"))
      {:ok, %LinkDeleted{}} = DeleteLinkOfUser.CommandHandler.handle(scope, "Ada1234", @now)

      assert {:error, :append_condition_failed} =
               EventStore.append(expiration_event("Ada1234", @later), condition)
    end

    test "fails the append given the logout of the login session after the read",
         %{scope: scope, session_token: session_token} do
      {_model, condition} =
        DecisionModel.build(EventStore,
          login_session: LoginSessionUser.new(scope.session_token_hash)
        )

      :ok = EndLoginSessionOfUser.CommandHandler.handle(session_token, @now)

      assert {:error, :append_condition_failed} =
               EventStore.append(expiration_event("Ada1234", @later), condition)
    end

    test "fails the append of a resolution given an expiration of the same link after the read",
         %{scope: scope} do
      {_model, condition} = DecisionModel.build(EventStore, link: LinkOfShortCode.new("Ada1234"))
      {:ok, _set} = CommandHandler.handle(scope, "Ada1234", command(@later), @now)

      event =
        ShortUrlResolved.to_event(%ShortUrlResolved{
          short_code: "Ada1234",
          target_url: "https://example.com/Ada1234",
          owner_email_address: "ada@example.com",
          resolved_at: @now
        })

      assert {:error, :append_condition_failed} = EventStore.append(event, condition)
    end
  end

  describe "using a link whose time of expiration is past" do
    setup do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")
      {:ok, _set} = CommandHandler.handle(scope, "Ada1234", command(@later), @now)
      %{scope: scope}
    end

    test "resolves to the target URL given a time before the time of expiration" do
      before_later = DateTime.add(@later, -1, :second)

      assert {:ok, %ShortUrlResolved{target_url: "https://example.com/Ada1234"}} =
               ResolveTargetUrlOfShortUrl.CommandHandler.handle("Ada1234", before_later)
    end

    test "resolves to not found and records no resolution given the time of expiration" do
      assert {:error, :not_found} =
               ResolveTargetUrlOfShortUrl.CommandHandler.handle("Ada1234", @later)

      query = %Query{items: [%QueryItem{types: [ShortUrlResolved.type_name()], tags: []}]}
      assert EventStore.read(query, []) == []
    end

    test "resolves to not found and records no resolution given a time after the time of expiration" do
      after_later = DateTime.add(@later, 1, :second)

      assert {:error, :not_found} =
               ResolveTargetUrlOfShortUrl.CommandHandler.handle("Ada1234", after_later)

      query = %Query{items: [%QueryItem{types: [ShortUrlResolved.type_name()], tags: []}]}
      assert EventStore.read(query, []) == []
    end

    test "counts the link against the link limit" do
      assert %ShortenTargetUrlForUser.LinkUsage{link_count: 1} =
               ShortenTargetUrlForUser.LinkUsage.of("ada@example.com")
    end

    test "returns short code taken given a shortening that chooses its short code" do
      assert {:error, :short_code_taken} = shorten(login_scope("grace@example.com"), "Ada1234")
    end

    test "deletes the link given a deletion by the owner", %{scope: scope} do
      assert {:ok, %LinkDeleted{short_code: "Ada1234"}} =
               DeleteLinkOfUser.CommandHandler.handle(scope, "Ada1234", @later)
    end
  end
end
