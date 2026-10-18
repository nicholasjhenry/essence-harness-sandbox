defmodule Shortener.Features.AssignPlanToUser.LiveTest do
  use ShortenerWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  describe "assigning a plan on the page" do
    test "shows the plan of the user given a valid submission", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/plans")

      view
      |> form("#assign-plan-form", command: %{email_address: "ada@example.com", plan: "pro"})
      |> render_submit()

      assert has_element?(view, "#plan-assignment-email", "ada@example.com")
      assert has_element?(view, "#plan-assignment-plan", "Pro")
    end

    test "shows an error given an email address with no domain", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/plans")

      view
      |> form("#assign-plan-form", command: %{email_address: "ada", plan: "pro"})
      |> render_submit()

      assert has_element?(view, "#assign-plan-form", "must have the form name@domain")
      refute has_element?(view, "#plan-assignment")
    end

    test "shows an error given the user was put on the plan before", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/plans")

      submit = fn ->
        view
        |> form("#assign-plan-form", command: %{email_address: "ada@example.com", plan: "pro"})
        |> render_submit()
      end

      submit.()
      submit.()

      assert has_element?(view, "#assign-plan-form", "the user is on this plan")
    end

    test "shows an error given the user is on the default plan", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/plans")

      view
      |> form("#assign-plan-form", command: %{email_address: "ada@example.com", plan: "free"})
      |> render_submit()

      assert has_element?(view, "#assign-plan-form", "the user is on this plan")
    end
  end
end
