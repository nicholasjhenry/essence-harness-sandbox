defmodule Shortener.Features.ResolveTargetUrlOfShortUrl.ResolutionTest do
  use Shortener.DataCase, async: false

  alias Shortener.Features.ResolveTargetUrlOfShortUrl.Resolution
  alias Shortener.Shared.LinkShortened

  defp shorten(short_code, target_url, owner \\ nil) do
    fact = %LinkShortened{
      short_code: short_code,
      target_url: target_url,
      owner_email_address: owner,
      shortened_at: DateTime.utc_now()
    }

    :ok = Shortener.EventStore.append(LinkShortened.to_event(fact), nil)
  end

  describe "resolving a short code" do
    test "gives the target URL of a link of a visitor" do
      shorten("Abc1234", "https://example.com/a")

      assert Resolution.resolve("Abc1234") == {:ok, "https://example.com/a"}
    end

    test "gives the target URL of a link of a user" do
      shorten("Abc1234", "https://example.com/b", "ada@example.com")

      assert Resolution.resolve("Abc1234") == {:ok, "https://example.com/b"}
    end

    test "gives the target URL of the link of the short code, and of no other link" do
      shorten("Abc1234", "https://example.com/a")
      shorten("Xyz9876", "https://example.com/z")

      assert Resolution.resolve("Xyz9876") == {:ok, "https://example.com/z"}
    end

    test "gives not found for a short code that no link has" do
      assert Resolution.resolve("Abc1234") == {:error, :not_found}
    end

    test "gives not found for a value that is not a short code" do
      assert Resolution.resolve("plans") == {:error, :not_found}
      assert Resolution.resolve("Abc-123") == {:error, :not_found}
    end
  end
end
