defmodule HyperLLM.Providers.Ollama do
  @behaviour HyperLLM.Provider

  @moduledoc """
  Provider implementation for Ollama.

  ## Configuration:

      config :hyper_llm, 
        ollama: [
          api_url: "http://localhost:11434",
          api_key: "ollama"
        ]
  """

  @impl true
  def completion(messages, config) do
    model = Keyword.fetch!(config, :model)

    {_request, response} =
      request("/chat",
        method: :post,
        receive_timeout: 30_000,
        json: %{
          model: model,
          messages: messages,
          stream: false
        }
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
