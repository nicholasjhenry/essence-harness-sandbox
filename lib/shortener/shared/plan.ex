defmodule Shortener.Shared.Plan do
  @moduledoc """
  A level of service of the link shortener, with a link limit.

  The plans are fixed. A link limit of `nil` permits any number of links.
  """

  @enforce_keys [:name, :title, :link_limit]
  defstruct [:name, :title, :link_limit]

  @type t :: %__MODULE__{name: String.t(), title: String.t(), link_limit: pos_integer() | nil}

  @spec all() :: [t()]
  def all do
    [
      %__MODULE__{name: "free", title: "Free", link_limit: 10},
      %__MODULE__{name: "pro", title: "Pro", link_limit: nil}
    ]
  end

  @spec names() :: [String.t()]
  def names, do: Enum.map(all(), & &1.name)

  @spec fetch(String.t()) :: {:ok, t()} | :error
  def fetch(name) do
    case Enum.find(all(), &(&1.name == name)) do
      nil -> :error
      plan -> {:ok, plan}
    end
  end

  @doc "The plan of a user who has no plan assignment."
  @spec default() :: t()
  def default do
    {:ok, free} = fetch("free")
    free
  end
end
