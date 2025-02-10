defmodule HyperLLM.ModelTest do
  use ExUnit.Case
  doctest HyperLLM.Model

  describe "new/1" do
    test "when provider and model are valid" do
      assert %HyperLLM.Model{provider: HyperLLM.Provider.OpenAI, model: "gpt-4o-mini"} =
               HyperLLM.Model.new!(provider: HyperLLM.Provider.OpenAI, model: "gpt-4o-mini")
    end

    test "when provider is not supported" do
      assert_raise ArgumentError,
                   "Unsupported provider: invalid/gpt-4o-mini.",
                   fn ->
                     HyperLLM.Model.new!(model: "invalid/gpt-4o-mini")
                   end
    end

    test "when model is not supported" do
      assert_raise ArgumentError,
                   "Model is not supported by provider: openai/invalid-model.",
                   fn ->
                     HyperLLM.Model.new!(model: "openai/invalid-model")
                   end
    end

    test "when model is invalid format" do
      assert_raise ArgumentError,
                   "Expected model in format: provider/model, got: invalid-format.",
                   fn ->
                     HyperLLM.Model.new!(model: "invalid-format")
                   end
    end
  end

  describe "parse_model/1" do
    test "when provider and model are valid" do
      assert {:ok, {HyperLLM.Provider.OpenAI, "gpt-4o-mini"}} =
               HyperLLM.Model.parse_model("openai/gpt-4o-mini")
    end

    test "when provider is invalid" do
      assert {:error, :invalid_provider} = HyperLLM.Model.parse_model("invalid/gpt-4o-mini")
    end

    test "when model is invalid" do
      assert {:error, :invalid_model} = HyperLLM.Model.parse_model("openai/invalid-model")
    end

    test "when model is invalid format" do
      assert {:error, :invalid_model_format} = HyperLLM.Model.parse_model("invalid-format")
    end
  end

  describe "list_providers/0" do
    test "returns a list of providers" do
      assert ["anthropic", "cloudflare", "groq", "ollama", "openai", "x_ai"] =
               HyperLLM.Model.list_providers()
    end
  end
end
