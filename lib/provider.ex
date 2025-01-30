defmodule HyperLLM.Provider do
  @moduledoc false

  @callback completion(messages :: [any], config :: map()) ::
              {:ok, String.t() | {:error, String.t()}}

  @callback models() :: [String.t()]
end
