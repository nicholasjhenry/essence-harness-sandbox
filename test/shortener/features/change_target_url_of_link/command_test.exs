defmodule Shortener.Features.ChangeTargetUrlOfLink.CommandTest do
  use Shortener.DataCase, async: true

  alias Shortener.Features.ChangeTargetUrlOfLink.Command

  @current "https://example.com/old"

  defp changeset(params), do: Command.changeset(%Command{}, params, @current)

  describe "validating the new target URL" do
    test "is valid given a new https target URL" do
      changeset = changeset(%{"target_url" => "https://example.com/new"})

      assert changeset.valid?
      assert Ecto.Changeset.get_field(changeset, :target_url) == "https://example.com/new"
    end

    test "removes the spaces at the start and the end given a target URL with spaces" do
      changeset = changeset(%{"target_url" => "  https://example.com/new  "})

      assert changeset.valid?
      assert Ecto.Changeset.get_field(changeset, :target_url) == "https://example.com/new"
    end

    test "returns an error given the target URL of the link" do
      assert %{target_url: ["must differ from the target URL of the link"]} =
               errors_on(changeset(%{"target_url" => @current}))
    end

    test "returns an error given the target URL of the link with spaces" do
      assert %{target_url: ["must differ from the target URL of the link"]} =
               errors_on(changeset(%{"target_url" => " " <> @current <> " "}))
    end

    test "returns an error given a URL with the ftp scheme" do
      assert %{target_url: ["must be an http or https URL with a host"]} =
               errors_on(changeset(%{"target_url" => "ftp://example.com"}))
    end

    test "returns an error given no target URL" do
      assert %{target_url: ["can't be blank"]} = errors_on(changeset(%{"target_url" => ""}))
    end
  end
end
