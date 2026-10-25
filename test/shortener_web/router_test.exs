defmodule ShortenerWeb.RouterTest do
  use ExUnit.Case, async: true

  alias Shortener.Shared.ShortCode

  describe "routing a path that a short code can take" do
    test "gives no route of a page a first segment that has the form of a short code" do
      first_segments =
        for %{path: path} <- Phoenix.Router.routes(ShortenerWeb.Router),
            segment <- path |> String.split("/", trim: true) |> Enum.take(1),
            not String.starts_with?(segment, ":"),
            do: segment

      assert first_segments != []
      refute Enum.any?(first_segments, &ShortCode.valid?/1)
    end
  end
end
