defmodule HyperLLM.Provider do
  @moduledoc """
  Defines the behaviour that all provider modules must implement.
  """

  @callback completion(messages :: [any], config :: map()) ::
              {:ok, String.t() | {:error, String.t()}}

  @callback has_model?(String.t()) :: boolean()
end
