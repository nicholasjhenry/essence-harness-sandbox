defmodule Shortener.Features.ListLinksOfUser.LinkListTest do
  use Shortener.DataCase, async: false

  alias Shortener.Features.ListLinksOfUser.LinkList
  alias Shortener.Shared.LinkShortened

  defp shorten(short_code, owner, shortened_at \\ ~U[2026-10-24 21:26:00Z]) do
    fact = %LinkShortened{
      short_code: short_code,
      target_url: "https://example.com/" <> short_code,
      owner_email_address: owner,
      shortened_at: shortened_at
    }

    :ok = Shortener.EventStore.append(LinkShortened.to_event(fact), nil)
  end

  defp short_codes(links), do: Enum.map(links, & &1.short_code)

  describe "listing the links of a user" do
    test "gives the links of the owner newest first given two links" do
      shorten("Older12", "ada@example.com", ~U[2026-10-24 10:00:00Z])
      shorten("Newer34", "ada@example.com", ~U[2026-10-24 11:00:00Z])

      assert [%LinkShortened{short_code: "Newer34"}, %LinkShortened{short_code: "Older12"}] =
               LinkList.of("ada@example.com")
    end

    test "gives the target URL and the time of shortening of each link" do
      shorten("Abc1234", "ada@example.com")

      assert [link] = LinkList.of("ada@example.com")
      assert link.target_url == "https://example.com/Abc1234"
      assert link.owner_email_address == "ada@example.com"
      assert link.shortened_at == ~U[2026-10-24 21:26:00Z]
    end

    test "excludes the links of a different user and of a visitor given three owners" do
      shorten("Ada1234", "ada@example.com")
      shorten("Grace12", "grace@example.com")
      shorten("Visit12", nil)

      assert short_codes(LinkList.of("ada@example.com")) == ["Ada1234"]
    end

    test "gives an empty list given an email address that owns no link" do
      shorten("Grace12", "grace@example.com")

      assert LinkList.of("ada@example.com") == []
    end

    test "gives the same links given the email address in upper case" do
      shorten("Ada1234", "ada@example.com")

      assert short_codes(LinkList.of("ADA@Example.com")) == ["Ada1234"]
    end
  end
end
