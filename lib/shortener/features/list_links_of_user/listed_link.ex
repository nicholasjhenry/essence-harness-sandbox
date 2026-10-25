defmodule Shortener.Features.ListLinksOfUser.ListedLink do
  @moduledoc """
  One row of the list of the links of a user: the link, the number of its
  resolutions, and its time of expiration, or `nil` if it has no expiration.
  """

  alias Shortener.Shared.LinkShortened

  @enforce_keys [:link, :resolution_count]
  defstruct [:link, :resolution_count, :expires_at]

  @type t :: %__MODULE__{
          link: LinkShortened.t(),
          resolution_count: non_neg_integer(),
          expires_at: DateTime.t() | nil
        }
end
