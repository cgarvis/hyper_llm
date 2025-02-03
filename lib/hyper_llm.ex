defmodule HyperLLM do
  @moduledoc false
  def config(provider) do
    Application.get_env(:hyper_llm, provider, [])
  end

  def config(provider, key, default) do
    Keyword.get(config(provider), key, default)
  end

  def config!(provider, key) do
    Keyword.fetch!(config(provider), key)
  end

  def set_config(provider, key, value) do
    Application.put_env(:hyper_llm, provider, Keyword.put(config(provider), key, value))
  end
end
