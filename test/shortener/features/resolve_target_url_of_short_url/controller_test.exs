defmodule Shortener.Features.ResolveTargetUrlOfShortUrl.ControllerTest do
  use ShortenerWeb.ConnCase, async: false

  alias Shortener.DCB.{Query, QueryItem}

  alias Shortener.Shared.{
    LinkExpirationSet,
    LinkShortened,
    LinkTargetUrlChanged,
    ShortUrlResolved
  }

  setup do
    fact = %LinkShortened{
      short_code: "Abc1234",
      target_url: "https://example.com/a/long/path?q=1",
      shortened_at: DateTime.utc_now()
    }

    :ok = Shortener.EventStore.append(LinkShortened.to_event(fact), nil)
  end

  defp resolutions do
    query = %Query{items: [%QueryItem{types: [ShortUrlResolved.type_name()], tags: []}]}
    Shortener.EventStore.read(query, [])
  end

  describe "GET /:short_code" do
    test "redirects to the target URL given the short URL of a link", %{conn: conn} do
      conn = get(conn, "/Abc1234")

      assert conn.status == 302
      assert get_resp_header(conn, "location") == ["https://example.com/a/long/path?q=1"]
    end

    test "records one resolution given the short URL of a link", %{conn: conn} do
      get(conn, "/Abc1234")

      assert [%{event: event}] = resolutions()
      assert ShortUrlResolved.from_event(event).short_code == "Abc1234"
    end

    test "answers not found given a short code that no link has", %{conn: conn} do
      conn = get(conn, "/Zzz9999")

      assert html_response(conn, 404) =~ "Not Found"
    end

    test "records no resolution given a short code that no link has", %{conn: conn} do
      get(conn, "/Zzz9999")

      assert resolutions() == []
    end

    test "answers not found and records no resolution given a link whose time of expiration is past",
         %{conn: conn} do
      fact = %LinkExpirationSet{
        short_code: "Abc1234",
        owner_email_address: "ada@example.com",
        expires_at: DateTime.add(DateTime.utc_now(), -60, :second),
        set_at: DateTime.add(DateTime.utc_now(), -120, :second)
      }

      :ok = Shortener.EventStore.append(LinkExpirationSet.to_event(fact), nil)
      conn = get(conn, "/Abc1234")

      assert html_response(conn, 404) =~ "Not Found"
      assert resolutions() == []
    end

    test "redirects to the new target URL given a link whose target URL changed", %{conn: conn} do
      fact = %LinkTargetUrlChanged{
        short_code: "Abc1234",
        owner_email_address: "ada@example.com",
        target_url: "https://example.com/new",
        changed_at: DateTime.utc_now()
      }

      :ok = Shortener.EventStore.append(LinkTargetUrlChanged.to_event(fact), nil)
      conn = get(conn, "/Abc1234")

      assert conn.status == 302
      assert get_resp_header(conn, "location") == ["https://example.com/new"]
    end

    test "leaves the page of a visitor at its path", %{conn: conn} do
      assert html_response(get(conn, ~p"/"), 200) =~ "Shorten a link"
    end

    test "leaves the login page at its path", %{conn: conn} do
      assert html_response(get(conn, ~p"/log-in"), 200) =~ "Send the login link"
    end
  end
end
