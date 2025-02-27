defmodule HyperLLM.Provider.Anthropic do
  @behaviour HyperLLM.Provider

  import HyperLLM.Provider

  @moduledoc """
  Provider implementation for Anthropic.

  https://docs.anthropic.com/en/api/messages

  ## Configuration

  `api_key` - The API key for the Anthropic API.

  `api_version` - The API version to use. Defaults to `2023-06-01`.

      congfig :hyper_llm, 
        anthropic: [
          api_key: "sk-...",
          api_version: "2023-06-01"
        ]
  """

  @models [
    "claude-3-5-sonnet-latest",
    "claude-3-5-sonnet-20240620",
    "claude-3-5-haiku-latest",
    "claude-3-5-haiku-20241022",
    "claude-3-opus-20240229",
    "claude-3-sonnet-20240229",
    "claude-3-haiku-20240307"
  ]

  @doc """
  See `HyperLLM.Chat.completion/3` for more information.
  """
  @impl HyperLLM.Provider
  @spec completion(HyperLLM.Provider.completion_params(), HyperLLM.Provider.completion_config()) ::
          {:ok, binary()} | {:error, binary()}
  def completion(params, config \\ []) do
    if !Map.has_key?(params, :messages) do
      raise ArgumentError, ":messages are required in params"
    end

    if !Map.has_key?(params, :model) do
      raise ArgumentError, ":model is required in config"
    end

    if !Map.has_key?(params, :max_tokens) do
      raise ArgumentError, ":max_tokens is required in params"
    end

    request("/messages",
      method: :post,
      receive_timeout: Keyword.get(config, :receive_timeout, 30_000),
      json: to_anthropic_params(params)
    )
    |> to_openai_response()
  end

  @impl HyperLLM.Provider
  @doc """
  Check if a model is supported by the provider.

  Supported Models:
  #{Enum.map_join(@models, "\n", &"* #{&1}")}
  """
  def model_supported?(model) when model in @models, do: true
  def model_supported?(_), do: false

  defp to_anthropic_params(params) do
    params
    |> rename_key(:stop, :stop_sequences, fn stop_sequences ->
      if is_list(stop_sequences) do
        stop_sequences
      else
        [stop_sequences]
      end
    end)
  end

  defp to_openai_response({request, %{status: 200, body: body}}) do
    content = hd(body["content"])
    usage = body["usage"]

    %{
      "id" => body["id"],
      "created" => DateTime.utc_now() |> DateTime.to_unix(),
      "model" => request.options.json.model,
      "object" => "chat.completion",
      "service_tier" => "default",
      "system_fingerprint" => nil,
      "choices" => [
        %{
          "index" => 0,
          "message" => %{
            "role" => "assistant",
            "content" => content["text"]
          },
          "logprobs" => nil,
          "finish_reason" => body["stop_reason"]
        }
      ],
      "usage" => %{
        "prompt_tokens" => Map.get(usage, "input_tokens", 0),
        "completion_tokens" => Map.get(usage, "output_tokens", 0),
        "total_tokens" => Map.get(usage, "input_tokens", 0) + Map.get(usage, "output_tokens", 0)
      }
    }
  end

  defp to_openai_response({_, %{status: 400, body: body}}), do: {:error, body["error"]["message"]}
  defp to_openai_response({_, %{status: 401}}), do: {:error, "Invalid API key"}
  defp to_openai_response({_, %{status: 404}}), do: {:error, "Not found"}
  defp to_openai_response({_, %{status: 500}}), do: {:error, "Server error"}
  defp to_openai_response({_, %{status: 502}}), do: {:error, "Bad gateway"}
  defp to_openai_response({_, %{status: 503}}), do: {:error, "Service unavailable"}
  defp to_openai_response({_, %{status: 504}}), do: {:error, "Gateway timeout"}
  defp to_openai_response({_, %{status: 505}}), do: {:error, "HTTP version not supported"}

  defp request(url, opts) do
    api_key = HyperLLM.config!(:anthropic, :api_key)
    api_version = HyperLLM.config(:anthropic, :api_version, "2023-06-01")

    req =
      Req.new(
        base_url: "https://api.anthropic.com/v1",
        headers: [
          {"x-api-key", api_key},
          {"anthropic-version", api_version}
        ],
        url: url
      )

    Req.run(req, opts)
  end
end
