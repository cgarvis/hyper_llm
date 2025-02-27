defmodule HyperLLM.Provider do
  @moduledoc """
  Defines the behaviour that all provider modules must implement.
  """

  @type completion_params :: %{
          # required
          messages: [%{role: String.t(), content: String.t()}],
          model: String.t(),
          # optional
          audio: map(),
          frequency_penalty: number(),
          logit_bias: map(),
          logprobs: boolean(),
          max_completion_tokens: integer(),
          metadata: map(),
          modalities: [String.t()],
          n: integer(),
          parallel_tool_calls: boolean(),
          prediction: map(),
          presence_penalty: number(),
          reasoning_effort: String.t(),
          response_format: map(),
          seed: integer(),
          service_tier: String.t(),
          stop: String.t() | [String.t()],
          store: boolean(),
          stream: boolean(),
          stream_options: map(),
          temperature: number(),
          tool_choice: String.t() | map(),
          tools: [map()],
          top_logprobs: integer(),
          top_p: number(),
          user: String.t(),
          # deprecated
          function_call: String.t() | map(),
          functions: [map()],
          max_tokens: integer()
        }

  @type completion_config :: [
          receive_timeout: integer()
        ]

  @callback completion(params :: map(), config :: keyword()) ::
              {:ok, map()} | {:error, String.t()}

  @callback model_supported?(String.t()) :: boolean()

  def rename_key(map, old_key, new_key)
      when is_map(map) and is_map_key(map, old_key) and is_list(new_key) do
    Enum.reduce(new_key, map, fn key, acc ->
      case Map.get(acc, old_key) do
        nil -> acc
        value -> put_in(acc, key, value)
      end
    end)
    |> Map.delete(old_key)
  end

  def rename_key(map, old_key, new_key) when is_map(map) and is_map_key(map, old_key) do
    map
    |> Map.put(new_key, Map.get(map, old_key))
    |> Map.delete(old_key)
  end

  def rename_key(map, _old_key, _new_key) when is_map(map), do: map

  def rename_key(map, old_key, new_key, transform)
      when is_map(map) and is_map_key(map, old_key) and is_function(transform, 1) do
    map
    |> Map.put(new_key, transform.(Map.get(map, old_key)))
    |> Map.delete(old_key)
  end

  def rename_key(map, _old_key, _new_key, _transform) when is_map(map), do: map
end
