defmodule HyperLLM.Provider.LlamaCPP do
  @behaviour HyperLLM.Provider

  @moduledoc """
  Provider implementation for LlamaCPP.

  LlamaCPP server that implements the OpenAI API format.
  https://github.com/ggerganov/llama.cpp/tree/master/examples/server

  ## Configuration

  `api_key` - The API key for the LlamaCPP API (optional).
  `base_url` - The base URL for the LlamaCPP API.

      config :hyper_llm, 
        llama_cpp: [
          api_key: "llamacpp",
          base_url: "http://localhost:8080"
        ]
  """

  @doc """
  See `HyperLLM.Chat.completion/3` for more information.
  """
  @impl HyperLLM.Provider
  @spec completion(HyperLLM.Provider.completion_params(), HyperLLM.Provider.completion_config()) ::
          {:ok, binary()} | {:error, binary()}
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

      %{status: 400, body: body} ->
        {:error, body.error.message}

      %{status: 401} ->
        {:error, "LlamaCPP API key is invalid"}

      %{status: 404} ->
        {:error, "LlamaCPP API not found"}

      %{status: 500} ->
        {:error, "LlamaCPP Server error"}

      _ ->
        {:error, "Unknown error"}
    end
  end

  @impl true
  @doc """
  Check if a model is supported by the provider.

  All models are supported as they are loaded into the server directly.
  """
  def model_supported?(_), do: true

  defp request(url, opts) do
    api_key = HyperLLM.config!(:llama_cpp, :api_key)
    base_url = HyperLLM.config(:llama_cpp, :base_url, "http://localhost:8080")

    req =
      Req.new(
        auth: {:bearer, api_key},
        base_url: base_url,
        url: url
      )

    Req.run(req, opts)
  end
end
