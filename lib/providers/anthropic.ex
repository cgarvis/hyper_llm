defmodule HyperLLM.Provider.Anthropic do
  @behaviour HyperLLM.Provider

  @moduledoc """
  Anthropic provider.
  """

  @models ["claude-3-5-sonnet-20240620"]

  @impl true
  def completion(_messages, _config) do
    {:error, "Anthropic not implemented"}
  end

  @impl true
  def models(), do: @models
end
