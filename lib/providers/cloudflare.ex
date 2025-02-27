defmodule HyperLLM.Provider.Cloudflare do
  @behaviour HyperLLM.Provider

  @moduledoc """
  Provider implementation for Cloudflare.

  Uses Cloudflare's [OpenAI compatibility API](https://developers.cloudflare.com/workers-ai/configuration/open-ai-compatibility/) for chat completions.

  ## Configuration

  `api_key` - The API key for the Cloudflare API.

  `account_id` - The account ID for the Cloudflare API.

      congfig :hyper_llm, 
        cloudflare: [
          api_key: "sk-...",
          account_id: "..."
        ]
  """

  @doc """
  See `HyperLLM.Chat.completion/3` for more information.
  """
  @impl HyperLLM.Provider
  def completion(params, config) do
    if !Map.has_key?(params, :messages) do
      raise ArgumentError, ":messages are required in params"
    end

    if !Map.has_key?(config, :model) do
      raise ArgumentError, ":model is required in config"
    end

    {_request, response} =
      request("/ai/v1/chat/completions",
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
        {:error, "Cloudflare API key is invalid"}

      %{status: 404} ->
        {:error, "Cloudflare API not found"}

      %{status: 500} ->
        {:error, "Cloudflare Server error"}

      _ ->
        {:error, "Unknown error"}
    end
  end

  @impl HyperLLM.Provider
  @doc """
  Checks if the model starts with `@`
  """
  def model_supported?(model) do
    String.starts_with?(model, "@")
  end

  defp request(url, opts) do
    api_key = HyperLLM.config!(:cloudflare, :api_key)
    account_id = HyperLLM.config!(:cloudflare, :account_id)

    req =
      Req.new(
        auth: {:bearer, api_key},
        base_url: "https://api.cloudflare.com/client/v4/accounts/#{account_id}",
        url: url
      )

    Req.run(req, opts)
  end
end
