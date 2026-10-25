defmodule Shortener.Shared.ShortCodeChoiceTest do
  use ExUnit.Case, async: true

  alias Shortener.Shared.{ShortCode, ShortCodeChoice}

  describe "giving the candidates of a decision" do
    test "gives three short codes that the link shortener makes given no chosen short code" do
      candidates = ShortCodeChoice.candidates(nil)

      assert length(candidates) == 3
      assert Enum.all?(candidates, &ShortCode.valid?/1)
    end

    test "gives the one chosen short code given a chosen short code" do
      assert ShortCodeChoice.candidates("Summer1") == ["Summer1"]
    end
  end
end
