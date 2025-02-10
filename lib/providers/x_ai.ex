defmodule HyperLLM.Provider.XAI do
  @behaviour HyperLLM.Provider

  @moduledoc """
  Provider implementation for X.ai.

  API Reference: [X.ai API Reference](https://docs.x.ai/docs/api-reference)

  ## Configuration

      config :hyper_llm,
        x_ai: [
          api_url: "https://api.x.ai/v1",
          api_key: "YOUR_API_KEY"
        ]

  """

  @models [
    "grok-vision-beta",
    "grok-2-vision-1212",
    "grok-2-vision",
    "grok-2-vision-latest",
    "grok-2-1212",
    "grok-2",
    "grok-2-latest",
    "grok-beta"
  ]

  @impl true
  def completion(messages, config) do
    model = Keyword.fetch!(config, :model)

    {_request, response} =
      request("/chat/completions",
        method: :post,
        receive_timeout: 30_000,
        json: %{
          model: model,
          messages: messages
        }
      )

    case response do
      %{status: 200, body: body} ->
        {:ok, body}

      %{status: 400, body: body} ->
        {:error, body.error.message}

      %{status: 401} ->
        {:error, "X.ai API key is invalid"}

      %{status: 403, body: body} ->
        {:error, body["error"]}

      %{status: 404} ->
        {:error, "X.ai endpoint not found"}

      %{status: 422, body: error} ->
        {:error, error}

      %{status: 500} ->
        {:error, "X.ai Server error"}

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
    api_key = HyperLLM.config!(:x_ai, :api_key)

    req =
      Req.new(
        auth: {:bearer, api_key},
        base_url: "https://api.x.ai/v1",
        url: url
      )

    Req.request(req, opts)
  end
end
