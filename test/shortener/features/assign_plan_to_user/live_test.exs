defmodule Shortener.Features.AssignPlanToUser.LiveTest do
  use ShortenerWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  describe "selecting a plan on the page" do
    test "redirects a visitor to the login page", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/log-in"}}} = live(conn, ~p"/plans")
    end

    test "shows the plan of the logged-in user, and has no email address field", %{conn: conn} do
      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/plans")

      assert has_element?(view, "#current-plan-email", "ada@example.com")
      assert has_element?(view, "#current-plan", "Free")
      refute has_element?(view, "#assign-plan-form input[name='command[email_address]']")
    end

    test "shows the new plan given the user selects Pro", %{conn: conn} do
      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/plans")

      view |> form("#assign-plan-form", command: %{plan: "pro"}) |> render_submit()

      assert has_element?(view, "#current-plan", "Pro")
    end

    test "shows an error given the user is on the plan", %{conn: conn} do
      {:ok, view, _html} = conn |> log_in_user("ada@example.com") |> live(~p"/plans")

      view |> form("#assign-plan-form", command: %{plan: "free"}) |> render_submit()

      assert has_element?(view, "#assign-plan-form", "you are on this plan")
    end
  end
end
