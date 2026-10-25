defmodule Shortener.Features.ListLinksOfUser.ListedLink do
  @moduledoc """
  One row of the list of the links of a user: the link, and the number of
  its resolutions.
  """

  alias Shortener.Shared.LinkShortened

  @enforce_keys [:link, :resolution_count]
  defstruct [:link, :resolution_count]

  @type t :: %__MODULE__{
          link: LinkShortened.t(),
          resolution_count: non_neg_integer()
        }
end
