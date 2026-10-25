defmodule Shortener.Features.ChangeTargetUrlOfLink.Command do
  @moduledoc """
  The request of the owner of a link to replace the target URL of the link
  with a new target URL.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Shortener.Shared.TargetUrl

  @primary_key false
  embedded_schema do
    field :target_url, :string
  end

  @typedoc """
  ## Fields

  - target_url: the new target URL
  """
  @type t :: %__MODULE__{target_url: String.t() | nil}

  @doc "The error of a new target URL that is the target URL of the link."
  @spec unchanged_message() :: String.t()
  def unchanged_message, do: "must differ from the target URL of the link"

  @spec changeset(t(), map(), String.t()) :: Ecto.Changeset.t()
  def changeset(command, attrs, current_target_url) when is_binary(current_target_url) do
    command
    |> cast(attrs, [:target_url])
    |> validate_required([:target_url])
    |> TargetUrl.validate(:target_url)
    |> validate_change(:target_url, fn :target_url, target_url ->
      if target_url == current_target_url,
        do: [target_url: unchanged_message()],
        else: []
    end)
  end
end
