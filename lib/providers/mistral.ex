defmodule HyperLLM.Provider.Mistral do
  @behaviour HyperLLM.Provider

  import HyperLLM.Provider

  @moduledoc """
  Provider implementation for Mistral.ai.

  https://docs.mistral.ai/api/

  ## Configuration

  `api_key` - The API key for the Mistral API.

      config :hyper_llm, 
        mistral: [
          api_key: "...",
        ]
  """

  @models [
    # premier models
    "codestral-latest",
    "mistral-large-latest",
    "pixtral-large-latest",
    "mistral-3b-latest",
    "mistral-8b-latest",
    "mistral-embed",
    "mistral-moderation-latest",
    # free models
    "mistral-small-latest",
    "pixtral-12b-2409",
    "open-mistral-nemo",
    "open-codestral-mamba"
  ]

  @doc """
  See `HyperLLM.Chat.completion/3` for more information.
  """
  @spec completion(HyperLLM.Provider.completion_params(), HyperLLM.Provider.completion_config()) ::
          {:ok, binary()} | {:error, binary()}
  @impl HyperLLM.Provider
  def completion(params, config \\ []) do
    if !Map.has_key?(params, :messages) do
      raise ArgumentError, ":messages are required in params"
    end

    if !Map.has_key?(params, :model) do
      raise ArgumentError, ":model is required in params"
    end

    {_request, response} =
      request("/v1/chat/completions",
        method: :post,
        receive_timeout: Keyword.get(config, :receive_timeout, 30_000),
        json: to_mistral_params(params)
      )

    case response do
      %{status: 200, body: body} ->
        {:ok, body}

      %{status: 401} ->
        {:error, "Invalid API key"}

      %{status: 429} ->
        {:error, "Rate limit exceeded"}

      %{status: status, body: %{"error" => %{"message" => message}}} ->
        {:error, "HTTP #{status}: #{message}"}

      _ ->
        {:error, "Unknown error"}
    end
  end

  @impl true
  @doc """
  Check if a model is supported by the provider.

  Supported Models:
  #{Enum.map_join(@models, "\n", &"* #{&1}")}
  """
  def model_supported?(model) when model in @models, do: true
  def model_supported?(_), do: false

  defp request(url, opts) do
    api_key = HyperLLM.config!(:mistral, :api_key)

    req =
      Req.new(
        auth: {:bearer, api_key},
        base_url: "https://api.mistral.ai",
        url: url
      )

    Req.run(req, opts)
  end

  defp to_mistral_params(params) do
    params
    |> rename_key(:seed, :random_seed)
  end
end
