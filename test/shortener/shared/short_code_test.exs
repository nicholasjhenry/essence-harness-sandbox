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

  describe "validating a chosen short code" do
    defp validate(attrs) do
      {%{}, %{short_code: :string}}
      |> Ecto.Changeset.cast(attrs, [:short_code])
      |> ShortCode.validate(:short_code)
    end

    test "gives the short code with no space at the start or the end given a valid short code" do
      changeset = validate(%{"short_code" => "  Summer1 "})

      assert changeset.valid?
      assert Ecto.Changeset.get_change(changeset, :short_code) == "Summer1"
    end

    test "gives no change given an empty field or a field of spaces" do
      for value <- ["", "   "] do
        changeset = validate(%{"short_code" => value})

        assert changeset.valid?
        assert Ecto.Changeset.get_change(changeset, :short_code) == nil
      end
    end

    test "gives the error given six characters, eight characters, a dash, or a letter that is not ASCII" do
      for value <- ["Summer", "Summer12", "Sum-mer", "Café123"] do
        assert %{short_code: ["must be seven characters from A–Z, a–z, and 0–9"]} =
                 errors_on(validate(%{"short_code" => value}))
      end
    end
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, _opts} -> message end)
  end
end
