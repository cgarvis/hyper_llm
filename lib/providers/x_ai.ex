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

  @doc """
  See `HyperLLM.Chat.completion/3` for more information.
  """
  @spec completion(HyperLLM.Provider.completion_params(), HyperLLM.Provider.completion_config()) ::
          {:ok, binary()} | {:error, binary()}
  @impl HyperLLM.Provider
  def completion(params, config) do
    if !Map.has_key?(params, :messages) do
      raise ArgumentError, ":messages are required in params"
    end

    if !Map.has_key?(config, :model) do
      raise ArgumentError, ":model is required in config"
    end

    {_request, response} =
      request("/chat/completions",
        method: :post,
        receive_timeout: Keyword.get(config, :receive_timeout, 30_000),
        json: params
      )

    case response do
      %{status: 200, body: body} ->
        {:ok, body}

      _ ->
        completion_error(response)
    end
  end

  defp completion_error(%{status: 400, body: body}), do: {:error, body.error.message}
  defp completion_error(%{status: 401}), do: {:error, "X.ai API key is invalid"}
  defp completion_error(%{status: 403, body: body}), do: {:error, body["error"]}
  defp completion_error(%{status: 404}), do: {:error, "X.ai endpoint not found"}
  defp completion_error(%{status: 422, body: error}), do: {:error, error}
  defp completion_error(%{status: 500}), do: {:error, "X.ai Server error"}
  defp completion_error(_), do: {:error, "Unknown error"}

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
