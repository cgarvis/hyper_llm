defmodule HyperLLM.Provider.Mistral do
  @behaviour HyperLLM.Provider

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

  @impl true
  @doc """
  See `HyperLLM.Chat.completion/3` for more information.
  """
  def completion(messages, config) do
    model = Keyword.get(config, :model, "mistral-small-latest")

    {_request, response} =
      request("/v1/chat/completions",
        method: :post,
        json: %{
          messages: messages,
          model: model
        }
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
end
