defmodule HyperLLM.Provider.Ollama do
  @behaviour HyperLLM.Provider

  @moduledoc """
  Provider implementation for Ollama.

  https://github.com/ollama/ollama/blob/main/docs/api.md#generate-a-chat-completion

  ## Configuration

  `api_url` - The URL for the Ollama API. Defaults to `http://localhost:11434`.

  `api_key` - The API key for the Ollama API.  Defaults to `ollama`.

      config :hyper_llm, 
        ollama: [
          api_url: "http://localhost:11434",
          api_key: "ollama"
        ]
  """

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

    if !Map.has_key?(config, :model) do
      raise ArgumentError, ":model is required in config"
    end

    {_request, response} =
      request("/chat",
        method: :post,
        receive_timeout: Keyword.get(config, :receive_timeout, 30_000),
        json: to_ollama_params(params)
      )

    case response do
      %{status: 200, body: body} ->
        {:ok, to_openai_response(body)}

      %{status: 400, body: body} ->
        {:error, body.error.message}

      %{status: 401} ->
        {:error, "Ollama API key is invalid"}

      %{status: 404} ->
        {:error, "Ollama model not found"}

      %{status: 500} ->
        {:error, "Ollama Server error"}

      _ ->
        {:error, "Unknown error"}
    end
  end

  @impl true
  @doc """
  Ollama supports all models.
  """
  def model_supported?(_), do: true

  defp to_ollama_params(params) do
    options = Map.drop(params, [:model, :messages, :tools, :stream, :keep_alive])

    params
    |> Map.take([:model, :messages, :tools, :stream, :keep_alive])
    |> Map.put(:options, options)
  end

  defp to_openai_response(body) do
    %{
      "id" => body["created_at"],
      "object" => "chat.completion",
      "created" => body["created_at"],
      "choices" => [
        %{
          "index" => 0,
          "message" => %{
            "role" => body["message"]["role"],
            "content" => body["message"]["content"]
          },
          "stop_reason" => body["done_reason"]
        }
      ],
      "usage" => %{
        "prompt_tokens" => Map.get(body, "prompt_eval_count", 0),
        "completion_tokens" => Map.get(body, "eval_count", 0),
        "total_tokens" => Map.get(body, "prompt_eval_count", 0) + Map.get(body, "eval_count", 0)
      }
    }
  end

  defp request(url, opts) do
    api_key = HyperLLM.config(:ollama, :api_key, "ollama")

    req =
      Req.new(
        auth: {:bearer, api_key},
        base_url: "http://localhost:11434/api",
        url: url
      )

    Req.request(req, opts)
  end
end
