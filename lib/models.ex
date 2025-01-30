defmodule HyperLLM.Models do
  @moduledoc false
  @providers [
    HyperLLM.Provider.Anthropic,
    HyperLLM.Provider.Groq,
    HyperLLM.Provider.OpenAI
  ]

  @model_to_provider Enum.reduce(@providers, %{}, fn provider_module, acc ->
                       Enum.reduce(provider_module.models(), acc, fn model, acc ->
                         Map.put(acc, model, provider_module)
                       end)
                     end)

  @doc "Get the provider module for a given model"
  def provider_for(model), do: Map.get(@model_to_provider, model)

  def provider_for!(model) do
    case provider_for(model) do
      nil -> raise "Provider for model #{model} not found"
      provider -> provider
    end
  end

  @doc "List all registered provider modules"
  def providers, do: @providers
end
