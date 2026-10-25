defmodule Shortener.Features.ChangeTargetUrlOfLink.CommandHandlerTest do
  use Shortener.DataCase, async: false

  import Shortener.LoginFixtures

  alias Shortener.DCB.{DecisionModel, Query, QueryItem}
  alias Shortener.EventStore
  alias Shortener.Features.ChangeTargetUrlOfLink.{Command, CommandHandler}
  alias Shortener.Features.{DeleteLinkOfUser, EndLoginSessionOfUser, ExpireLinkOfUser}
  alias Shortener.Features.{ResolveTargetUrlOfShortUrl, ShortenTargetUrlForUser}
  alias Shortener.Projections.{LinkOfShortCode, LoginSessionUser}

  alias Shortener.Shared.{
    LinkDeleted,
    LinkShortened,
    LinkTargetUrlChanged,
    OwnedLink,
    ShortUrlResolved
  }

  @now ~U[2026-10-25 12:00:00.000000Z]
  @later ~U[2026-10-26 12:00:00Z]
  @new "https://example.com/new"

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

  defp expire(scope, short_code, expires_at) do
    command = %ExpireLinkOfUser.Command{expires_at: expires_at}
    ExpireLinkOfUser.CommandHandler.handle(scope, short_code, command, @now)
  end

  defp command(target_url), do: %Command{target_url: target_url}

  defp changes do
    query = %Query{items: [%QueryItem{types: [LinkTargetUrlChanged.type_name()], tags: []}]}
    EventStore.read(query, [])
  end

  defp change_event(short_code, target_url) do
    LinkTargetUrlChanged.to_event(%LinkTargetUrlChanged{
      short_code: short_code,
      owner_email_address: "ada@example.com",
      target_url: target_url,
      changed_at: @now
    })
  end

  describe "changing the target URL of a link" do
    test "appends one target URL change given a link of the user" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")

      assert {:ok,
              %LinkTargetUrlChanged{
                short_code: "Ada1234",
                owner_email_address: "ada@example.com",
                target_url: @new,
                changed_at: @now
              }} = CommandHandler.handle(scope, "Ada1234", command(@new), @now)

      assert [_change] = changes()

      assert {:ok, %LinkOfShortCode{link: %LinkShortened{target_url: @new}}} =
               OwnedLink.of("ada@example.com", "Ada1234")
    end

    test "gives the latest target URL given a second change" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")
      {:ok, _changed} = CommandHandler.handle(scope, "Ada1234", command(@new), @now)

      assert {:ok, _changed} =
               CommandHandler.handle(scope, "Ada1234", command("https://example.com/newer"), @now)

      assert [_first, _second] = changes()

      assert {:ok,
              %LinkOfShortCode{link: %LinkShortened{target_url: "https://example.com/newer"}}} =
               OwnedLink.of("ada@example.com", "Ada1234")
    end

    test "changes the link given a later time of expiration" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")
      {:ok, _set} = expire(scope, "Ada1234", @later)

      assert {:ok, %LinkTargetUrlChanged{}} =
               CommandHandler.handle(scope, "Ada1234", command(@new), @now)
    end

    test "returns not found given a short code of no link" do
      scope = login_scope("ada@example.com")

      assert {:error, :not_found} = CommandHandler.handle(scope, "Nolink1", command(@new), @now)
      assert changes() == []
    end

    test "returns not found given a link of a different user" do
      {:ok, _link} = shorten(login_scope("grace@example.com"), "Grace12")
      scope = login_scope("ada@example.com")

      assert {:error, :not_found} = CommandHandler.handle(scope, "Grace12", command(@new), @now)
      assert changes() == []
    end

    test "returns not found given a link of a visitor" do
      shorten_for_visitor("Visit12")
      scope = login_scope("ada@example.com")

      assert {:error, :not_found} = CommandHandler.handle(scope, "Visit12", command(@new), @now)
      assert changes() == []
    end

    test "returns not found given a deleted link" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")
      {:ok, _deleted} = DeleteLinkOfUser.CommandHandler.handle(scope, "Ada1234", @now)

      assert {:error, :not_found} = CommandHandler.handle(scope, "Ada1234", command(@new), @now)
      assert changes() == []
    end

    test "returns not found given a value that is not a short code" do
      scope = login_scope("ada@example.com")

      assert {:error, :not_found} =
               CommandHandler.handle(scope, "not-a-code", command(@new), @now)

      assert changes() == []
    end

    test "returns not found given a new target URL with the ftp scheme" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")

      assert {:error, :not_found} =
               CommandHandler.handle(scope, "Ada1234", command("ftp://example.com"), @now)

      assert changes() == []
    end

    test "returns unchanged given the target URL of the link" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")

      assert {:error, :unchanged} =
               CommandHandler.handle(
                 scope,
                 "Ada1234",
                 command("https://example.com/Ada1234"),
                 @now
               )

      assert changes() == []
    end

    test "returns unchanged given the target URL of the link with spaces" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")

      assert {:error, :unchanged} =
               CommandHandler.handle(
                 scope,
                 "Ada1234",
                 command("  https://example.com/Ada1234 "),
                 @now
               )

      assert changes() == []
    end

    test "returns expired given a link whose time of expiration is past" do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")
      {:ok, _set} = expire(scope, "Ada1234", @later)

      assert {:error, :expired} =
               CommandHandler.handle(scope, "Ada1234", command(@new), @later)

      assert changes() == []
    end

    test "returns not logged in given an ended login session" do
      session_token = start_login_session("ada@example.com")
      scope = ShortenerWeb.UserAuth.scope_for_session_token(session_token)
      {:ok, _link} = shorten(scope, "Ada1234")
      :ok = EndLoginSessionOfUser.CommandHandler.handle(session_token, @now)

      assert {:error, :not_logged_in} =
               CommandHandler.handle(scope, "Ada1234", command(@new), @now)

      assert changes() == []
    end
  end

  describe "deciding a target URL change under a conflicting event" do
    setup do
      session_token = start_login_session("ada@example.com")
      scope = ShortenerWeb.UserAuth.scope_for_session_token(session_token)
      {:ok, _link} = shorten(scope, "Ada1234")
      %{scope: scope, session_token: session_token}
    end

    defp link_condition do
      {_model, condition} = DecisionModel.build(EventStore, link: LinkOfShortCode.new("Ada1234"))
      condition
    end

    test "fails the append given a target URL change of the same link after the read",
         %{scope: scope} do
      condition = link_condition()
      {:ok, _changed} = CommandHandler.handle(scope, "Ada1234", command(@new), @now)

      assert {:error, :append_condition_failed} =
               EventStore.append(change_event("Ada1234", "https://example.com/other"), condition)
    end

    test "fails the append given a deletion of the same link after the read", %{scope: scope} do
      condition = link_condition()
      {:ok, %LinkDeleted{}} = DeleteLinkOfUser.CommandHandler.handle(scope, "Ada1234", @now)

      assert {:error, :append_condition_failed} =
               EventStore.append(change_event("Ada1234", @new), condition)
    end

    test "fails the append given an expiration of the same link after the read", %{scope: scope} do
      condition = link_condition()
      {:ok, _set} = expire(scope, "Ada1234", @later)

      assert {:error, :append_condition_failed} =
               EventStore.append(change_event("Ada1234", @new), condition)
    end

    test "fails the append given the logout of the login session after the read",
         %{scope: scope, session_token: session_token} do
      {_model, condition} =
        DecisionModel.build(EventStore,
          login_session: LoginSessionUser.new(scope.session_token_hash)
        )

      :ok = EndLoginSessionOfUser.CommandHandler.handle(session_token, @now)

      assert {:error, :append_condition_failed} =
               EventStore.append(change_event("Ada1234", @new), condition)
    end

    test "fails the append of a resolution given a target URL change of the same link after the read",
         %{scope: scope} do
      condition = link_condition()
      {:ok, _changed} = CommandHandler.handle(scope, "Ada1234", command(@new), @now)

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

  describe "using a link whose target URL changed" do
    setup do
      scope = login_scope("ada@example.com")
      {:ok, _link} = shorten(scope, "Ada1234")
      %{scope: scope}
    end

    test "resolves to the new target URL and records it given a change", %{scope: scope} do
      {:ok, _changed} = CommandHandler.handle(scope, "Ada1234", command(@new), @now)

      assert {:ok, %ShortUrlResolved{target_url: @new}} =
               ResolveTargetUrlOfShortUrl.CommandHandler.handle("Ada1234", @now)

      query = %Query{items: [%QueryItem{types: [ShortUrlResolved.type_name()], tags: []}]}
      assert [%{event: event}] = EventStore.read(query, [])
      assert ShortUrlResolved.from_event(event).target_url == @new
    end

    test "keeps the old target URL of a resolution given a resolution before the change",
         %{scope: scope} do
      {:ok, _resolved} = ResolveTargetUrlOfShortUrl.CommandHandler.handle("Ada1234", @now)
      {:ok, _changed} = CommandHandler.handle(scope, "Ada1234", command(@new), @now)

      query = %Query{items: [%QueryItem{types: [ShortUrlResolved.type_name()], tags: []}]}
      assert [%{event: event}] = EventStore.read(query, [])
      assert ShortUrlResolved.from_event(event).target_url == "https://example.com/Ada1234"
    end

    test "counts the link once against the link limit given a change", %{scope: scope} do
      {:ok, _changed} = CommandHandler.handle(scope, "Ada1234", command(@new), @now)

      assert %ShortenTargetUrlForUser.LinkUsage{link_count: 1} =
               ShortenTargetUrlForUser.LinkUsage.of("ada@example.com")
    end

    test "returns short code taken given a shortening that chooses its short code",
         %{scope: scope} do
      {:ok, _changed} = CommandHandler.handle(scope, "Ada1234", command(@new), @now)

      assert {:error, :short_code_taken} = shorten(login_scope("grace@example.com"), "Ada1234")
    end
  end
end
