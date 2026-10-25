defmodule Shortener.Features.ListLinksOfUser.LinkListTest do
  use Shortener.DataCase, async: false

  alias Shortener.Features.ListLinksOfUser.{LinkList, ListedLink}
  alias Shortener.Features.ResolveTargetUrlOfShortUrl
  alias Shortener.Shared.{LinkShortened, LinkTargetUrlChanged}

  @now ~U[2026-10-25 12:00:00Z]

  defp shorten(short_code, owner, shortened_at \\ ~U[2026-10-24 21:26:00Z]) do
    fact = %LinkShortened{
      short_code: short_code,
      target_url: "https://example.com/" <> short_code,
      owner_email_address: owner,
      shortened_at: shortened_at
    }

    :ok = Shortener.EventStore.append(LinkShortened.to_event(fact), nil)
  end

  defp resolve(short_code),
    do: {:ok, _resolved} = ResolveTargetUrlOfShortUrl.CommandHandler.handle(short_code, @now)

  defp short_codes(listed_links), do: Enum.map(listed_links, & &1.link.short_code)

  defp resolution_counts(listed_links),
    do: Map.new(listed_links, &{&1.link.short_code, &1.resolution_count})

  describe "listing the links of a user" do
    test "gives the links of the owner newest first given two links" do
      shorten("Older12", "ada@example.com", ~U[2026-10-24 10:00:00Z])
      shorten("Newer34", "ada@example.com", ~U[2026-10-24 11:00:00Z])

      assert [
               %ListedLink{link: %LinkShortened{short_code: "Newer34"}},
               %ListedLink{link: %LinkShortened{short_code: "Older12"}}
             ] = LinkList.of("ada@example.com")
    end

    test "gives the target URL and the time of shortening of each link" do
      shorten("Abc1234", "ada@example.com")

      assert [%ListedLink{link: link}] = LinkList.of("ada@example.com")
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

  describe "counting the resolutions of the links of a user" do
    test "gives the count 0 given a link with no resolution" do
      shorten("Abc1234", "ada@example.com")

      assert [%ListedLink{resolution_count: 0}] = LinkList.of("ada@example.com")
    end

    test "gives each link its own count given two links with resolutions" do
      shorten("Abc1234", "ada@example.com")
      shorten("Xyz9876", "ada@example.com")
      resolve("Abc1234")
      resolve("Abc1234")
      resolve("Xyz9876")

      assert resolution_counts(LinkList.of("ada@example.com")) == %{
               "Abc1234" => 2,
               "Xyz9876" => 1
             }
    end

    test "changes no count of the user given a resolution of a link of a different user" do
      shorten("Ada1234", "ada@example.com")
      shorten("Grace12", "grace@example.com")
      resolve("Grace12")

      assert resolution_counts(LinkList.of("ada@example.com")) == %{"Ada1234" => 0}
    end
  end

  describe "listing the links of a user after a target URL change" do
    test "gives the new target URL given a change of the target URL of a link" do
      shorten("Abc1234", "ada@example.com")
      shorten("Def5678", "ada@example.com")

      fact = %LinkTargetUrlChanged{
        short_code: "Abc1234",
        owner_email_address: "ada@example.com",
        target_url: "https://example.com/new",
        changed_at: @now
      }

      :ok = Shortener.EventStore.append(LinkTargetUrlChanged.to_event(fact), nil)

      targets = Map.new(LinkList.of("ada@example.com"), &{&1.link.short_code, &1.link.target_url})

      assert targets == %{
               "Abc1234" => "https://example.com/new",
               "Def5678" => "https://example.com/Def5678"
             }
    end
  end
end
