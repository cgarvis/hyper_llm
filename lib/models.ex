defmodule HyperLLM.Models do
  @providers %{
    "anthropic" => HyperLLM.Provider.Anthropic,
    "groq" => HyperLLM.Provider.Groq,
    "openai" => HyperLLM.Provider.OpenAI
  }

  @doc """
  Get the provider for a given model.

  Example:

      iex> HyperLLM.Models.get_provider("openai/gpt-4o-mini")
      {:ok, {HyperLLM.Provider.OpenAI, "gpt-4o-mini"}}

      iex> HyperLLM.Models.get_provider("anthropic/claude-3-5-sonnet-20240620")
      {:ok, {HyperLLM.Provider.Anthropic, "claude-3-5-sonnet-20240620"}}
  """
  def get_provider(model) when is_binary(model) do
    case String.split(model, "/", parts: 2) do
      [provider, model] ->
        case Map.get(@providers, provider) do
          nil ->
            {:error, :invalid_provider}

          provider ->
            if provider.has_model?(model) do
              {:ok, {provider, model}}
            else
              {:error, :invalid_model}
            end
        end

      _ ->
        {:error, :invalid_model_format}
    end
  end

  @doc """
  List all registered provider modules.

  Example:

      iex> HyperLLM.Models.list_providers()
      ["anthropic", "groq", "openai"]
  """
  def list_providers, do: Map.keys(@providers)
end
