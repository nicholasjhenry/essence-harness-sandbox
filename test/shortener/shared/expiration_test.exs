defmodule Shortener.Shared.ExpirationTest do
  use ExUnit.Case, async: true

  alias Shortener.Shared.Expiration

  @now ~U[2026-10-25 12:00:00Z]

  describe "comparing a time of expiration with the time now" do
    test "returns false given no time of expiration" do
      refute Expiration.passed?(nil, @now)
    end

    test "returns false given a later time of expiration" do
      refute Expiration.passed?(DateTime.add(@now, 1, :second), @now)
    end

    test "returns true given the time now" do
      assert Expiration.passed?(@now, @now)
    end

    test "returns true given an earlier time of expiration" do
      assert Expiration.passed?(DateTime.add(@now, -1, :second), @now)
    end
  end
end
