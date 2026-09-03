defmodule AverzianoWeb.Live.HandVariant do
  @moduledoc """
  The two hand presentations the prototypes exist to compare.

  `:ventaglio` (1a) overlaps the ten cards into an arc; `:griglia` (1b) lays
  them out on a 2x5 grid. Every screen reads the variant from the `mano` query
  parameter so the two can be flipped between while walking the flow.
  """

  @variants %{"ventaglio" => :ventaglio, "griglia" => :griglia}

  @doc """
  Resolves the `mano` query parameter, falling back to the fan.
  """
  @spec from_params(map()) :: :ventaglio | :griglia
  def from_params(params) do
    Map.get(@variants, params["mano"], :ventaglio)
  end

  @doc """
  The query string that keeps the current variant across navigation.
  """
  @spec to_param(:ventaglio | :griglia) :: String.t()
  def to_param(variant), do: Atom.to_string(variant)

  @doc """
  The other variant, for the compare toggle.
  """
  @spec other(:ventaglio | :griglia) :: :ventaglio | :griglia
  def other(:ventaglio), do: :griglia
  def other(:griglia), do: :ventaglio

  @doc """
  Human label for a variant.
  """
  @spec label(:ventaglio | :griglia) :: String.t()
  def label(:ventaglio), do: "Mano a ventaglio"
  def label(:griglia), do: "Mano a griglia 2×5"
end
