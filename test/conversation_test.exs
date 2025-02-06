defmodule HyperLLM.ConversationTest do
  use ExUnit.Case
  doctest HyperLLM.Conversation, except: [run: 1, run!: 1]

  test "start conversation" do
    conv = HyperLLM.Conversation.start(model: "openai/gpt-4o-mini")
    assert conv.thread == []
    assert conv.model.model == "gpt-4o-mini"
    assert conv.model.provider == HyperLLM.Provider.OpenAI
  end

  test "append message" do
    conv = HyperLLM.Conversation.start(model: "openai/gpt-4o-mini")
    conv = HyperLLM.Conversation.append(conv, "Hello")
    assert conv.thread == [%{role: :user, content: "Hello"}]
  end

  test "append messages" do
    conv = HyperLLM.Conversation.start(model: "openai/gpt-4o-mini")
    conv = HyperLLM.Conversation.append(conv, ["Hello", "World"])

    assert conv.thread == [
             %{role: :user, content: "Hello"},
             %{role: :user, content: "World"}
           ]
  end

  test "run conversation" do
    defmodule TestProvider do
      @behaviour HyperLLM.Provider
      def completion(_messages, _opts) do
        {:ok,
         %{
           "choices" => [
             %{
               "message" => %{
                 "role" => "assistant",
                 "content" => "How can I assist you today?"
               }
             }
           ]
         }}
      end

      def has_model?(_model), do: true
    end

    conv = HyperLLM.Conversation.start(provider: TestProvider, model: "test")
    conv = HyperLLM.Conversation.append(conv, "Hello")

    assert {:ok, conv} = HyperLLM.Conversation.run(conv)

    assert conv.thread == [
             %{role: :user, content: "Hello"},
             %{role: :assistant, content: "How can I assist you today?"}
           ]
  end
end
