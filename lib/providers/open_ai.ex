defmodule HyperLLM.Provider.OpenAI do
  @behaviour HyperLLM.Provider

  @moduledoc """
  OpenAI provider.

  Configuration:

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
    model = Keyword.get(config, :model_name, "gpt-4o-mini")

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

  def completion(messages, config, pid) when is_pid(pid) do
    model = Keyword.get(config, :model_name, "gpt-4o-mini")

    {_request, response} =
      request("/chat/completions",
        method: :post,
        receive_timeout: 30_000,
        json: %{
          model: model,
          messages: messages,
          stream: true
        },
        sse: [
          events: fn events, {req, resp} ->
            for event <- events do
              case event.data do
                "[DONE]" ->
                  send(pid, {:completion_end, ""})

                _ ->
                  data = Jason.decode!(event.data)

                  case data["object"] do
                    "chat.completion.chunk" ->
                      choice = data["choices"] |> List.first()
                      send(pid, {:completion_data, get_in(choice, ["delta", "content"])})

                    true ->
                      send(pid, {:unknown, event.data})
                  end
              end
            end

            {:cont, {req, resp}}
          end
        ]
      )

    case response do
      %{status: 200, body: _} ->
        :ok

      _ ->
        {:error, "Unknown error"}
    end
  end

  @impl true
  def models(), do: @models

  defp request(url, opts) do
    api_key = HyperLLM.config!(:openai, :api_key)

    req =
      Req.new(
        auth: {:bearer, api_key},
        base_url: "https://api.openai.com/v1",
        headers: [
          {"OpenAI-Beta", "assistants=v2"}
        ],
        url: url,
        plugins: [ReqSSE]
      )

    Req.run(req, opts)
  end
end
