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

  describe "checking the form of a short code" do
    test "is true for a generated short code" do
      assert ShortCode.valid?(ShortCode.generate())
    end

    test "is false for a value of a different length, a character that is not a letter or a digit, and a value that is not a string" do
      refute ShortCode.valid?("Abc123")
      refute ShortCode.valid?("Abc12345")
      refute ShortCode.valid?("Abc-123")
      refute ShortCode.valid?("Abcé123")
      refute ShortCode.valid?(nil)
    end
  end
end
