defmodule Shortener.Shared.ShortCodeTest do
  use ExUnit.Case, async: true

  alias Shortener.Shared.ShortCode

  describe "generating a short code" do
    test "gives seven letters or digits" do
      for _ <- 1..200, do: assert(ShortCode.generate() =~ ~r/\A[A-Za-z0-9]{7}\z/)
    end

    test "gives a different short code on each call" do
      codes = for _ <- 1..200, do: ShortCode.generate()
      assert length(Enum.uniq(codes)) == 200
    end
  end
end
