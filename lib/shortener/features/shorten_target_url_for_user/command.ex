defmodule Shortener.Features.ShortenTargetUrlForUser.Command do
  @moduledoc """
  The request of a logged-in user to shorten a target URL, with the short
  code that the user chose, if any. The user is the owner of the link.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Shortener.Shared.{ShortCode, TargetUrl}

  @primary_key false
  embedded_schema do
    field :target_url, :string
    field :short_code, :string
  end

  @typedoc """
  ## Fields

  A command has these fields:

  - target_url: the target URL to shorten
  - short_code: the short code that the user chose, or nil
  """
  @type t :: %__MODULE__{target_url: String.t() | nil, short_code: String.t() | nil}

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(command, attrs) do
    command
    |> cast(attrs, [:target_url, :short_code])
    |> validate_required([:target_url])
    |> TargetUrl.validate(:target_url)
    |> ShortCode.validate(:short_code)
  end
end
