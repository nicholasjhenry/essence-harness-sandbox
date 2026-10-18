defmodule Shortener.Features.ResolveTargetUrlOfShortUrl.ControllerTest do
  use ShortenerWeb.ConnCase, async: false

  alias Shortener.Shared.LinkShortened

  setup do
    fact = %LinkShortened{
      short_code: "Abc1234",
      target_url: "https://example.com/a/long/path?q=1",
      shortened_at: DateTime.utc_now()
    }

    :ok = Shortener.EventStore.append(LinkShortened.to_event(fact), nil)
  end

  describe "GET /:short_code" do
    test "redirects to the target URL given the short URL of a link", %{conn: conn} do
      conn = get(conn, "/Abc1234")

      assert conn.status == 302
      assert get_resp_header(conn, "location") == ["https://example.com/a/long/path?q=1"]
    end

    test "answers not found given a short code that no link has", %{conn: conn} do
      conn = get(conn, "/Zzz9999")

      assert html_response(conn, 404) =~ "Not Found"
    end

    test "leaves the page of a visitor at its path", %{conn: conn} do
      assert html_response(get(conn, ~p"/"), 200) =~ "Shorten a link"
    end

    test "leaves the login page at its path", %{conn: conn} do
      assert html_response(get(conn, ~p"/log-in"), 200) =~ "Send the login link"
    end
  end
end
