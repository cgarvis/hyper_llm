defmodule HyperLLM.Provider.OpenAI do
  @behaviour HyperLLM.Provider

  @moduledoc """
  Provider implementation for OpenAI.

  https://platform.openai.com/docs/api-reference/chat

  ## Configuration:

      congfig :hyper_llm, 
        openai: [
          api_key: "sk-..."
        ]
  """

  @models [
    "gpt-3.5-turbo",
    "gpt-3.5-turbo-0125",
    "gpt-3.5-turbo-1106",
    "gpt-3.5-turbo-instruct",
    "gpt-4-turbo",
    "gpt-4-turbo-2024-04-09",
    "gpt-4-turbo-preview",
    "gpt-4-0125-preview",
    "gpt-4-1106-preview",
    "gpt-4",
    "gpt-4-0613",
    "gpt-4-0314",
    "gpt-4o-2024-11-20",
    "gpt-4o-2024-08-06",
    "gpt-4o-2024-05-13",
    "gpt-4o-mini",
    "gpt-4o-mini-2024-07-18",
    "o1",
    "o1-mini",
    "o1-preview"
  ]

  @impl true
  def completion(messages, config) do
    model = Keyword.get(config, :model, "gpt-4o-mini")

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
        choices = body["choices"]
        choice = List.first(choices)
        {:ok, choice["message"]["content"]}

      %{status: 400, body: body} ->
        {:error, body.error.message}

      %{status: 401} ->
        {:error, "OpenAI API key is invalid"}

      %{status: 404} ->
        {:error, "OpenAI API not found"}

      %{status: 500} ->
        {:error, "OpenAI Server error"}

      _ ->
        {:error, "Unknown error"}
    end
  end

  @impl true
  @doc """
  Check if a model is supported by the provider.

  Currently the only supported models are:
  #{Enum.map_join(@models, "\n", &"* #{&1}")}
  """
  def has_model?(model) when model in @models, do: true
  def has_model?(_), do: false

  defp request(url, opts) do
    api_key = HyperLLM.config!(:openai, :api_key)

    req =
      Req.new(
        auth: {:bearer, api_key},
        base_url: "https://api.openai.com/v1",
        headers: [
          {"OpenAI-Beta", "assistants=v2"}
        ],
        url: url
      )

    Req.run(req, opts)
  end
end
