defmodule Shortener.Features.AssignPlanToUser.CommandHandlerTest do
  use Shortener.DataCase, async: false

  import Shortener.LoginFixtures

  alias Shortener.Features.AssignPlanToUser.{Command, CommandHandler, PlanOfUser}
  alias Shortener.Features.EndLoginSessionOfUser
  alias Shortener.Shared.PlanAssignedToUser

  @now ~U[2026-10-17 12:00:00.000000Z]

  defp command(plan) do
    %Command{}
    |> Command.changeset(%{"plan" => plan})
    |> Ecto.Changeset.apply_action!(:insert)
  end

  describe "assigning a plan" do
    test "puts the user of the scope on the plan given the user is on the default plan" do
      scope = login_scope("ada@example.com")

      assert {:ok,
              %PlanAssignedToUser{
                email_address: "ada@example.com",
                plan: "pro",
                assigned_at: @now
              }} =
               CommandHandler.handle(scope, command("pro"), @now)

      assert PlanOfUser.of("ada@example.com").name == "pro"
    end

    test "returns plan already assigned given the user has no plan assignment and the plan is the default plan" do
      assert {:error, :plan_already_assigned} =
               CommandHandler.handle(login_scope("ada@example.com"), command("free"), @now)
    end

    test "returns plan already assigned given the user is on the plan" do
      scope = login_scope("ada@example.com")
      {:ok, _} = CommandHandler.handle(scope, command("pro"), @now)

      assert {:error, :plan_already_assigned} = CommandHandler.handle(scope, command("pro"), @now)
    end

    test "puts the user on a second plan given the user is on a different plan" do
      scope = login_scope("ada@example.com")
      {:ok, _} = CommandHandler.handle(scope, command("pro"), @now)

      assert {:ok, %PlanAssignedToUser{plan: "free"}} =
               CommandHandler.handle(scope, command("free"), @now)
    end

    test "puts only the user of the scope on the plan" do
      {:ok, _} = CommandHandler.handle(login_scope("ada@example.com"), command("pro"), @now)

      assert PlanOfUser.of("grace@example.com").name == "free"
    end

    test "returns not logged in given the login session of the scope is ended" do
      session_token = start_login_session("ada@example.com")
      scope = ShortenerWeb.UserAuth.scope_for_session_token(session_token)
      :ok = EndLoginSessionOfUser.CommandHandler.handle(session_token, @now)

      assert {:error, :not_logged_in} = CommandHandler.handle(scope, command("pro"), @now)
      assert PlanOfUser.of("ada@example.com").name == "free"
    end
  end

  describe "validating the command" do
    test "is not valid given a plan that does not exist" do
      changeset = Command.changeset(%Command{}, %{"plan" => "gold"})
      assert %{plan: ["is invalid"]} = errors_on(changeset)
    end
  end
end
