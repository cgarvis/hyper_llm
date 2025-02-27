defmodule HyperLLM.Provider.Groq do
  @behaviour HyperLLM.Provider

  @moduledoc """
  Groq provider.

  https://console.groq.com/docs/api-reference

  ## Configuration

  `api_key` - The API key for the Groq API.

      congfig :hyper_llm, 
        groq: [
          api_key: "sk-...",
        ]
  """

  @models [
    "deepseek-r1-distill-llama-70b",
    "distil-whisper-large-v3-en",
    "gemma2-9b-it",
    "llama-3.1-8b-instant",
    "llama-3.2-11b-vision-preview",
    "llama-3.2-1b-preview",
    "llama-3.2-90b-vision-preview",
    "llama-3.2-3b-preview",
    "llama-3.3-70b-specdec",
    "llama-3.3-70b-versatile",
    "llama-guard-3-8b",
    "llama3-70b-8192",
    "llama3-8b-8192",
    "mixtral-8x7b-32768",
    "whisper-large-v3-turbo",
    "whisper-large-v3"
  ]

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
        {:error, body["error"]["message"]}

      %{status: 401} ->
        {:error, "Groq API key is invalid"}

      %{status: 404} ->
        {:error, "Groq API not found"}

      %{status: 500} ->
        {:error, "Groq Server error"}

      error ->
        {:error, error}
    end
  end

  @impl HyperLLM.Provider
  @doc """
  Check if a model is supported by the provider.

  Supported Models:
  #{Enum.map_join(@models, "\n", &"* #{&1}")}
  """
  def model_supported?(model) when model in @models, do: true
  def model_supported?(_), do: false

  defp request(url, opts) do
    api_key = HyperLLM.config!(:groq, :api_key)

    req =
      Req.new(
        auth: {:bearer, api_key},
        base_url: "https://api.groq.com/openai/v1/",
        url: url
      )

    Req.run(req, opts)
  end
end
