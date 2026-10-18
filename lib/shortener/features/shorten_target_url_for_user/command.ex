defmodule Shortener.Features.ShortenTargetUrlForUser.Command do
  @moduledoc """
  The request of a logged-in user to shorten a target URL. The user is the
  owner of the link.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Shortener.Shared.TargetUrl

  @primary_key false
  embedded_schema do
    field :target_url, :string
  end

  @type t :: %__MODULE__{target_url: String.t()}

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(command, attrs) do
    command
    |> cast(attrs, [:target_url])
    |> validate_required([:target_url])
    |> TargetUrl.validate(:target_url)
  end
end
