defmodule Shortener.Features.AssignPlanToUser.CommandHandlerTest do
  use Shortener.DataCase, async: false

  alias Shortener.Features.AssignPlanToUser.{Command, CommandHandler}
  alias Shortener.Shared.PlanAssignedToUser

  @now ~U[2026-10-17 12:00:00.000000Z]

  defp command(email_address, plan) do
    %Command{}
    |> Command.changeset(%{"email_address" => email_address, "plan" => plan})
    |> Ecto.Changeset.apply_action!(:insert)
  end

  describe "assigning a plan" do
    test "puts the user on the plan given the user is on the default plan" do
      assert {:ok,
              %PlanAssignedToUser{
                email_address: "ada@example.com",
                plan: "pro",
                assigned_at: @now
              }} =
               CommandHandler.handle(command("ada@example.com", "pro"), @now)
    end

    test "returns plan already assigned given the user has no plan assignment and the plan is the default plan" do
      assert {:error, :plan_already_assigned} =
               CommandHandler.handle(command("ada@example.com", "free"), @now)
    end

    test "returns plan already assigned given the user is on the plan" do
      {:ok, _} = CommandHandler.handle(command("ada@example.com", "pro"), @now)

      assert {:error, :plan_already_assigned} =
               CommandHandler.handle(command("ada@example.com", "pro"), @now)
    end

    test "puts the user on a second plan given the user is on a different plan" do
      {:ok, _} = CommandHandler.handle(command("ada@example.com", "pro"), @now)

      assert {:ok, %PlanAssignedToUser{plan: "free"}} =
               CommandHandler.handle(command("ada@example.com", "free"), @now)
    end

    test "returns plan already assigned given the same email address in a different case" do
      {:ok, _} = CommandHandler.handle(command("ada@example.com", "pro"), @now)

      assert {:error, :plan_already_assigned} =
               CommandHandler.handle(command("  ADA@Example.com ", "pro"), @now)
    end

    test "puts a second user on the plan given the first user is on it" do
      {:ok, _} = CommandHandler.handle(command("ada@example.com", "pro"), @now)

      assert {:ok, %PlanAssignedToUser{email_address: "grace@example.com"}} =
               CommandHandler.handle(command("grace@example.com", "pro"), @now)
    end
  end

  describe "validating the command" do
    test "is not valid given an email address with no domain" do
      changeset = Command.changeset(%Command{}, %{"email_address" => "ada", "plan" => "pro"})
      assert %{email_address: ["must have the form name@domain"]} = errors_on(changeset)
    end

    test "is not valid given a plan that does not exist" do
      changeset =
        Command.changeset(%Command{}, %{"email_address" => "ada@example.com", "plan" => "gold"})

      assert %{plan: ["is invalid"]} = errors_on(changeset)
    end
  end
end
