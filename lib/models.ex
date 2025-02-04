defmodule HyperLLM.Models do
  @moduledoc """
  Determine the provider and model for a given model name.
  """

  @providers %{
    "anthropic" => HyperLLM.Provider.Anthropic,
    "cloudflare" => HyperLLM.Provider.Cloudflare,
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
    with [provider, model] <- String.split(model, "/", parts: 2),
         provider_module when not is_nil(provider_module) <- Map.get(@providers, provider),
         true <- provider_module.has_model?(model) do
      {:ok, {provider_module, model}}
    else
      nil -> {:error, :invalid_provider}
      false -> {:error, :invalid_model}
      _ -> {:error, :invalid_model_format}
    end
  end

  @doc """
  List all registered provider modules.

  Example:

      iex> HyperLLM.Models.list_providers()
      ["anthropic", "cloudflare", "groq", "openai"]
  """
  def list_providers, do: Map.keys(@providers)
end
