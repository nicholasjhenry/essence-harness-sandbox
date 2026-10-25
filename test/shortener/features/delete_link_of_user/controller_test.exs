defmodule Shortener.Features.DeleteLinkOfUser.ControllerTest do
  use ShortenerWeb.ConnCase, async: false

  alias Shortener.Shared.LinkShortened

  defp shorten(short_code, owner) do
    fact = %LinkShortened{
      short_code: short_code,
      target_url: "https://example.com/" <> short_code,
      owner_email_address: owner,
      shortened_at: ~U[2026-10-24 21:26:00Z]
    }

    :ok = Shortener.EventStore.append(LinkShortened.to_event(fact), nil)
  end

  describe "deleting a link from the list of the links of a user" do
    test "redirects to the list with a message given a link of the user", %{conn: conn} do
      shorten("Ada1234", "ada@example.com")

      conn = conn |> log_in_user("ada@example.com") |> delete(~p"/links/Ada1234")

      assert redirected_to(conn) == ~p"/links"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "Link deleted."
      assert build_conn() |> get(~p"/Ada1234") |> response(404)
    end

    test "keeps the link and shows an error given a link of a different user", %{conn: conn} do
      shorten("Grace12", "grace@example.com")

      conn = conn |> log_in_user("ada@example.com") |> delete(~p"/links/Grace12")

      assert redirected_to(conn) == ~p"/links"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You own no link with this short code."

      assert redirected_to(build_conn() |> get(~p"/Grace12"), 302) ==
               "https://example.com/Grace12"
    end

    test "redirects to the login page given a visitor", %{conn: conn} do
      shorten("Ada1234", "ada@example.com")

      conn = delete(conn, ~p"/links/Ada1234")

      assert redirected_to(conn) == ~p"/log-in"

      assert redirected_to(build_conn() |> get(~p"/Ada1234"), 302) ==
               "https://example.com/Ada1234"
    end
  end
end
