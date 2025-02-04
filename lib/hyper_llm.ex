defmodule HyperLLM do
  @moduledoc false
  @spec config(atom()) :: list()
  def config(provider) do
    Application.get_env(:hyper_llm, provider, [])
  end

  @spec config(atom(), atom(), any()) :: any()
  def config(provider, key, default \\ nil) do
    Keyword.get(config(provider), key, default)
  end

  @spec config!(atom(), atom()) :: any()
  def config!(provider, key) do
    case Keyword.get(config(provider), key) do
      nil -> raise "Missing config: :#{provider} requires :#{key}"
      value -> value
    end
  end

  @doc """
  Sets a config for a provider.
  This is useful if you are not using HyperLLM from within an Elixir application like LiveBook

  ## Example

      iex> HyperLLM.set_config(:openai, :api_key, "sk-1234567890")
      :ok
  """
  def set_config(provider, key, value) do
    Application.put_env(:hyper_llm, provider, Keyword.put(config(provider), key, value))
  end
end
