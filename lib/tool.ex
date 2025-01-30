defmodule HyperLLM.Tool do
  @moduledoc """
  Defines the behaviour that all workflow tool modules must implement.

  Each tool module must implement the `call/1` callback, which takes a keyword list
  of inputs and returns a tuple containing a result atom and output keyword list.
  """

  @doc """
  Executes the tool with the given input values.

  ## Parameters
    * `input` - A keyword list containing the tool-specific input values
    
  ## Returns
    * `{result, output}` - A tuple containing:
      * `result` - An atom indicating the result of the tool execution (e.g., :ok, :error, :high, :low)
      * `output` - A keyword list containing the tool's output values
  """
  @callback call(input :: keyword()) :: {atom(), keyword()}

  # @callback input_schema() :: map()
end
