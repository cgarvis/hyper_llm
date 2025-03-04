defmodule HyperLLM.Model do
  @moduledoc """
  Determine the provider and model for a given model name.
  """

  @providers %{
    "anthropic" => HyperLLM.Provider.Anthropic,
    "cloudflare" => HyperLLM.Provider.Cloudflare,
    "groq" => HyperLLM.Provider.Groq,
    "llama_cpp" => HyperLLM.Provider.LlamaCPP,
    "mistral" => HyperLLM.Provider.Mistral,
    "openai" => HyperLLM.Provider.OpenAI,
    "ollama" => HyperLLM.Provider.Ollama,
    "vllm" => HyperLLM.Provider.VLLM,
    "x_ai" => HyperLLM.Provider.XAI
  }

  @type t :: %__MODULE__{}
  @type config :: [Keyword.t()]

  @enforce_keys [:provider, :model, :config]
  defstruct [:provider, :model, :config]

  def new!(opts) when is_list(opts) do
    case {Keyword.get(opts, :provider), Keyword.get(opts, :model)} do
      {nil, nil} ->
        raise ArgumentError, "opts must include [:model] or [:provider, :model]"

      {nil, model} when is_binary(model) ->
        case parse_model(model) do
          {:ok, {provider, model}} ->
            %__MODULE__{
              provider: provider,
              model: model,
              config: Keyword.drop(opts, [:provider, :model])
            }

          {:error, :invalid_provider} ->
            raise ArgumentError, "Unsupported provider: #{model}."

          {:error, :invalid_model} ->
            raise ArgumentError, "Model is not supported by provider: #{model}."

          {:error, :invalid_model_format} ->
            raise ArgumentError, "Expected model in format: provider/model, got: #{model}."
        end

      {provider, model} when is_binary(model) ->
        %__MODULE__{
          provider: provider,
          model: model,
          config: Keyword.drop(opts, [:provider, :model])
        }
    end
  end

  @doc """
  Parse a model string into a provider and model.

  Example:

      iex> HyperLLM.Model.parse_model("openai/gpt-4o-mini")
      {:ok, {HyperLLM.Provider.OpenAI, "gpt-4o-mini"}}

      iex> HyperLLM.Model.parse_model("anthropic/claude-3-5-sonnet-20240620")
      {:ok, {HyperLLM.Provider.Anthropic, "claude-3-5-sonnet-20240620"}}
  """
  def parse_model(model) when is_binary(model) do
    with [provider, model] <- String.split(model, "/", parts: 2),
         provider_module when not is_nil(provider_module) <- Map.get(@providers, provider),
         true <- provider_module.model_supported?(model) do
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

      iex> HyperLLM.Model.list_providers()
      ["anthropic", "cloudflare", "groq", "llama_cpp", "mistral", "ollama", "openai", "vllm", "x_ai"]
  """
  @spec list_providers() :: [String.t()]
  def list_providers, do: Map.keys(@providers)
end
