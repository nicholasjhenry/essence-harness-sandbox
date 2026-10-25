defmodule Shortener.Features.ExpireLinkOfUser.CommandTest do
  use Shortener.DataCase, async: true

  alias Shortener.Features.ExpireLinkOfUser.Command

  @now ~U[2026-10-25 12:00:00Z]

  defp changeset(params), do: Command.changeset(%Command{}, params, @now)

  describe "validating the time of expiration" do
    test "casts the time as UTC given the value of a datetime-local field" do
      changeset = changeset(%{"expires_at" => "2026-10-26T12:00"})

      assert changeset.valid?
      assert Ecto.Changeset.get_field(changeset, :expires_at) == ~U[2026-10-26 12:00:00Z]
    end

    test "returns an error given the time now" do
      assert %{expires_at: ["must be after the time now"]} =
               errors_on(changeset(%{"expires_at" => "2026-10-25T12:00"}))
    end

    test "returns an error given an earlier time" do
      assert %{expires_at: ["must be after the time now"]} =
               errors_on(changeset(%{"expires_at" => "2026-10-25T11:59"}))
    end

    test "returns an error given no time" do
      assert %{expires_at: ["can't be blank"]} = errors_on(changeset(%{"expires_at" => ""}))
    end
  end
end
