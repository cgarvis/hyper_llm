defmodule HyperLLM.Provider.Groq do
  @behaviour HyperLLM.Provider

  @moduledoc """
  Groq provider.
  """

  @models ["llama-3.1-8b-instruct"]

  @impl true
  def completion(_messages, _config) do
    {:error, "Groq not implemented"}
  end

  @impl true
  def models(), do: @models
end
