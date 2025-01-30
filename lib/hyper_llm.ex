defmodule HyperLLM do
  @moduledoc false
  def config(provider) do
    Application.get_env(:hyper_llm, provider, [])
  end

  def config!(provider, key) do
    Keyword.fetch!(config(provider), key)
  end
end
