defmodule HyperLLM.Provider.Groq do
  @behaviour HyperLLM.Provider

  @moduledoc """
  Groq provider.
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

  @impl true
  def completion(messages, config) do
    model = Keyword.get(config, :model, "llama-3.1-8b-instruct")

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

  @impl true
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
