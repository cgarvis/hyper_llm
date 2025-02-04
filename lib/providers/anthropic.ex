defmodule HyperLLM.Provider.Anthropic do
  @behaviour HyperLLM.Provider

  @moduledoc """
  Provider implementation for Anthropic.

  https://docs.anthropic.com/en/api/messages

  ## Configuration:

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

  @impl true
  def completion(messages, config) do
    model = Keyword.get(config, :model, "claude-3-5-sonnet-20240620")
    max_tokens = Keyword.get(config, :max_tokens, 1024)

    {_request, response} =
      request("/messages",
        method: :post,
        json: %{
          max_tokens: max_tokens,
          messages: messages,
          model: model
        }
      )

    case response do
      %{status: 200, body: body} ->
        choices = body["content"]
        choice = List.first(choices)
        {:ok, Map.get(choice, "text")}

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
