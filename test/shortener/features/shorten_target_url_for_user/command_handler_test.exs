defmodule Shortener.Features.ShortenTargetUrlForUser.CommandHandlerTest do
  use Shortener.DataCase, async: false

  import Shortener.LoginFixtures

  alias Shortener.DCB.DecisionModel
  alias Shortener.EventStore
  alias Shortener.Features.{AssignPlanToUser, EndLoginSessionOfUser}
  alias Shortener.Features.ShortenTargetUrlForUser.{Command, CommandHandler, LinkUsage}
  alias Shortener.Shared.LinkShortened

  @now ~U[2026-10-17 12:00:00.000000Z]
  @url "https://example.com/a/long/path"

  defp command(target_url \\ @url) do
    %Command{}
    |> Command.changeset(%{"target_url" => target_url})
    |> Ecto.Changeset.apply_action!(:insert)
  end

  defp assign_plan(email_address, plan) do
    command =
      %AssignPlanToUser.Command{}
      |> AssignPlanToUser.Command.changeset(%{"plan" => plan})
      |> Ecto.Changeset.apply_action!(:insert)

    {:ok, _} = AssignPlanToUser.CommandHandler.handle(login_scope(email_address), command, @now)
  end

  defp shorten_links(email_address, count) do
    scope = login_scope(email_address)

    for n <- 1..count do
      {:ok, _} =
        CommandHandler.handle(
          scope,
          command(),
          ["#{String.first(email_address)}code#{String.pad_leading("#{n}", 2, "0")}"],
          @now
        )
    end
  end

  describe "shortening a target URL for a user" do
    test "makes a link with the user as owner given the user is under the link limit" do
      assert {:ok,
              %LinkShortened{
                short_code: "aaaaaaa",
                owner_email_address: "ada@example.com",
                target_url: @url
              }} =
               CommandHandler.handle(
                 login_scope("ADA@example.com "),
                 command(),
                 ["aaaaaaa"],
                 @now
               )
    end

    test "tags the event with the short code and the user" do
      {:ok, _} =
        CommandHandler.handle(login_scope("ada@example.com"), command(), ["aaaaaaa"], @now)

      query = %Shortener.DCB.Query{items: [%Shortener.DCB.QueryItem{types: ["LinkShortened"]}]}
      [%{event: %{tags: tags}}] = EventStore.read(query, [])
      assert "short_code:aaaaaaa" in tags
      assert Enum.any?(tags, &String.starts_with?(&1, "user:"))
      refute Enum.any?(tags, &String.contains?(&1, "ada@example.com"))
    end

    test "returns link limit reached given a user on the Free plan with ten links" do
      shorten_links("ada@example.com", 10)

      assert {:error, :link_limit_reached} =
               CommandHandler.handle(login_scope("ada@example.com"), command(), ["bbbbbbb"], @now)

      assert %LinkUsage{link_count: 10} = LinkUsage.of("ada@example.com")
    end

    test "makes the eleventh link given a user on the Pro plan" do
      assign_plan("ada@example.com", "pro")
      shorten_links("ada@example.com", 10)

      assert {:ok, %LinkShortened{}} =
               CommandHandler.handle(login_scope("ada@example.com"), command(), ["bbbbbbb"], @now)
    end

    test "returns link limit reached given a user with eleven links moves from Pro to Free" do
      assign_plan("ada@example.com", "pro")
      shorten_links("ada@example.com", 11)
      assign_plan("ada@example.com", "free")

      assert {:error, :link_limit_reached} =
               CommandHandler.handle(login_scope("ada@example.com"), command(), ["bbbbbbb"], @now)
    end

    test "does not count the links of a different user or of a visitor" do
      shorten_links("grace@example.com", 10)
      shorten_links("ada@example.com", 9)

      visitor_link = %LinkShortened{short_code: "visitor", target_url: @url, shortened_at: @now}
      :ok = EventStore.append(LinkShortened.to_event(visitor_link), nil)

      assert {:ok, %LinkShortened{owner_email_address: "ada@example.com"}} =
               CommandHandler.handle(login_scope("ada@example.com"), command(), ["bbbbbbb"], @now)
    end

    test "returns short code taken given a link has each candidate" do
      {:ok, _} =
        CommandHandler.handle(login_scope("grace@example.com"), command(), ["aaaaaaa"], @now)

      assert {:error, :short_code_taken} =
               CommandHandler.handle(login_scope("ada@example.com"), command(), ["aaaaaaa"], @now)
    end

    test "fails the append given a link of the same user after the read" do
      projections = [
        user_link_count:
          Shortener.Features.ShortenTargetUrlForUser.UserLinkCount.new("ada@example.com")
      ]

      {_model, condition} = DecisionModel.build(EventStore, projections)

      {:ok, _} =
        CommandHandler.handle(login_scope("ada@example.com"), command(), ["aaaaaaa"], @now)

      event =
        LinkShortened.to_event(%LinkShortened{
          short_code: "bbbbbbb",
          target_url: @url,
          shortened_at: @now
        })

      assert {:error, :append_condition_failed} = EventStore.append(event, condition)
    end

    test "fails the append given a plan assignment of the user after the read" do
      projections = [user_plan: Shortener.Projections.UserPlan.new("ada@example.com")]
      {_model, condition} = DecisionModel.build(EventStore, projections)

      assign_plan("ada@example.com", "pro")

      event =
        LinkShortened.to_event(%LinkShortened{
          short_code: "aaaaaaa",
          target_url: @url,
          shortened_at: @now
        })

      assert {:error, :append_condition_failed} = EventStore.append(event, condition)
    end

    test "appends given a plan assignment of a different user after the read" do
      projections = [user_plan: Shortener.Projections.UserPlan.new("ada@example.com")]
      {_model, condition} = DecisionModel.build(EventStore, projections)

      assign_plan("grace@example.com", "pro")

      event =
        LinkShortened.to_event(%LinkShortened{
          short_code: "aaaaaaa",
          target_url: @url,
          shortened_at: @now
        })

      assert :ok = EventStore.append(event, condition)
    end
  end

  describe "authorizing the shortening" do
    test "returns not logged in given the login session of the scope is ended" do
      session_token = start_login_session("ada@example.com")
      scope = ShortenerWeb.UserAuth.scope_for_session_token(session_token)
      :ok = EndLoginSessionOfUser.CommandHandler.handle(session_token, @now)

      assert {:error, :not_logged_in} = CommandHandler.handle(scope, command(), ["aaaaaaa"], @now)
      assert %LinkUsage{link_count: 0} = LinkUsage.of("ada@example.com")
    end

    test "fails the append given the logout of the login session after the read" do
      session_token = start_login_session("ada@example.com")
      scope = ShortenerWeb.UserAuth.scope_for_session_token(session_token)

      projections = [
        login_session: Shortener.Projections.LoginSessionUser.new(scope.session_token_hash)
      ]

      {_model, condition} = DecisionModel.build(EventStore, projections)
      :ok = EndLoginSessionOfUser.CommandHandler.handle(session_token, @now)

      event =
        LinkShortened.to_event(%LinkShortened{
          short_code: "aaaaaaa",
          target_url: @url,
          owner_email_address: "ada@example.com",
          shortened_at: @now
        })

      assert {:error, :append_condition_failed} = EventStore.append(event, condition)
    end
  end

  describe "reading the link usage" do
    test "gives the default plan and no links given a user with no events" do
      assert %LinkUsage{link_count: 0, plan: %{name: "free"}} = LinkUsage.of("ada@example.com")
    end
  end
end
