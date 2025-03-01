defmodule HyperLLM.Provider.VLLM do
  @moduledoc """
  Provider implementation for vLLM.

  https://docs.vllm.ai/en/latest/getting_started/quickstart.html#quickstart-online
  """

  @behaviour HyperLLM.Provider

  @doc """
  See `HyperLLM.Chat.completion/3` for more information.
  """
  @impl HyperLLM.Provider
  def completion(params, config \\ []) do
    if !Map.has_key?(params, :messages) do
      raise ArgumentError, ":messages are required in params"
    end

    if !Map.has_key?(params, :model) do
      raise ArgumentError, ":model is required in params"
    end

    {_request, response} =
      request("/v1/chat/completions",
        method: :post,
        receive_timeout: Keyword.get(config, :receive_timeout, 30_000),
        json: to_vllm_params(params)
      )

    case response do
      %{status: 200, body: body} ->
        {:ok, body}

      %{status: 400, body: body} ->
        {:error, body.error.message}

      %{status: 401} ->
        {:error, "VLLM API key is invalid"}

      %{status: 404} ->
        {:error, "VLLM model not found"}

      %{status: 500} ->
        {:error, "VLLM Server error"}
    end
  end

  @impl HyperLLM.Provider
  def model_supported?(_), do: true

  defp request(url, opts) do
    api_key = HyperLLM.config(:vllm, :api_key, "vllm")

    req =
      Req.new(
        auth: {:bearer, api_key},
        base_url: HyperLLM.config(:vllm, :base_url, "http://localhost:8000"),
        url: url
      )

    Req.request(req, opts)
  end

  defp to_vllm_params(params) do
    params
  end
end
