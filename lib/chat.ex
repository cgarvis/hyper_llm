defmodule HyperLLM.Chat do
  @moduledoc """
  HyperLLM.Chat is a single interface for interacting with LLM providers.
  The interface uses the OpenAI chat completion API. https://platform.openai.com/docs/api-reference/chat
  """

  @doc """
  ## Example

      iex> HyperLLM.Chat.completion("openai/gpt-4o-mini", [%{role: :user, content: "Hello"}], [])
      {:ok, %{
        "id": "chatcmpl-123",
        "object": "chat.completion",
        "created": 1677652288,
        "model": "gpt-4o-mini",
        "system_fingerprint": "fp_44709d6fcb",
        "choices": [{
          "index": 0,
          "message": {
            "role": "assistant",
            "content": "Hello there, how may I assist you today?",
          },
          "logprobs": null,
          "finish_reason": "stop"
        }],
        "service_tier": "default",
        "usage": {
          "prompt_tokens": 9,
          "completion_tokens": 12,
          "total_tokens": 21,
          "completion_tokens_details": {
            "reasoning_tokens": 0,
            "accepted_prediction_tokens": 0,
            "rejected_prediction_tokens": 0
          }
        }
      }}
  """

  @spec completion(String.t(), list(), Keyword.t()) :: {:ok, binary()} | {:error, binary()}
  def completion(model_name, messages, opts) when is_binary(model_name) do
    HyperLLM.Model.new!(model: model_name) |> completion(messages, opts)
  end

  @spec completion(HyperLLM.Model.t(), list(), Keyword.t()) ::
          {:ok, binary()} | {:error, binary()}
  def completion(%HyperLLM.Model{} = model, messages, opts) do
    opts =
      model.config
      |> Keyword.merge(opts)
      |> Keyword.put(:model, model.model)

    model.provider.completion(messages, opts)
  end
end
