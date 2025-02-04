defmodule HyperLLM.ModelsTest do
  use ExUnit.Case
  doctest HyperLLM.Models

  describe "get_provider/1" do
    test "when provider and model are valid" do
      assert {:ok, {HyperLLM.Provider.OpenAI, "gpt-4o-mini"}} =
               HyperLLM.Models.get_provider("openai/gpt-4o-mini")
    end

    test "when provider is invalid" do
      assert {:error, :invalid_provider} = HyperLLM.Models.get_provider("invalid/gpt-4o-mini")
    end

    test "when model is invalid" do
      assert {:error, :invalid_model} = HyperLLM.Models.get_provider("openai/invalid-model")
    end
  end

  describe "list_providers/0" do
    test "returns a list of providers" do
      assert ["anthropic", "groq", "openai"] = HyperLLM.Models.list_providers()
    end
  end
end
