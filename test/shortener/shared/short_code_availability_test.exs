defmodule Shortener.Shared.ShortCodeAvailabilityTest do
  use Shortener.DataCase, async: false

  alias Shortener.EventStore
  alias Shortener.Shared.{LinkDeleted, LinkShortened, ShortCodeAvailability}

  @now ~U[2026-10-25 12:00:00.000000Z]

  defp shorten(short_code) do
    fact = %LinkShortened{
      short_code: short_code,
      target_url: "https://example.com/" <> short_code,
      owner_email_address: "ada@example.com",
      shortened_at: @now
    }

    :ok = EventStore.append(LinkShortened.to_event(fact), nil)
  end

  defp delete(short_code) do
    fact = %LinkDeleted{
      short_code: short_code,
      owner_email_address: "ada@example.com",
      deleted_at: @now
    }

    :ok = EventStore.append(LinkDeleted.to_event(fact), nil)
  end

  describe "checking the availability of a short code" do
    test "gives available given a short code that no link has" do
      assert ShortCodeAvailability.check("Summer1") == :available
    end

    test "gives taken given a short code that a link has" do
      shorten("Summer1")

      assert ShortCodeAvailability.check("Summer1") == :taken
    end

    test "gives taken given a short code of a deleted link" do
      shorten("Summer1")
      delete("Summer1")

      assert ShortCodeAvailability.check("Summer1") == :taken
    end

    test "gives available given a short code that differs only in case from the short code of a link" do
      shorten("Summer1")

      assert ShortCodeAvailability.check("summer1") == :available
    end

    test "gives nil given no short code" do
      assert ShortCodeAvailability.check(nil) == nil
    end

    test "gives nil given a value that does not have the form of a short code" do
      assert ShortCodeAvailability.check("abc") == nil
      assert ShortCodeAvailability.check("Summer-") == nil
    end
  end
end
