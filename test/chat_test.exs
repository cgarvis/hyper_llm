defmodule HyperLLM.ChatTest do
  use ExUnit.Case
  doctest HyperLLM.Chat

  test "start chat" do
    chat = HyperLLM.Chat.start(model: "gpt-4o-mini")
    assert chat.messages == []
    assert chat.provider == HyperLLM.Provider.OpenAI
    assert chat.config == [model: "gpt-4o-mini"]
  end

  test "append message" do
    chat = HyperLLM.Chat.start(model: "gpt-4o-mini")
    chat = HyperLLM.Chat.append(chat, "Hello")
    assert chat.messages == [%HyperLLM.Chat.Message{role: :user, content: "Hello"}]
  end

  test "append messages" do
    chat = HyperLLM.Chat.start(model: "gpt-4o-mini")
    chat = HyperLLM.Chat.append(chat, ["Hello", "World"])

    assert chat.messages == [
             %HyperLLM.Chat.Message{role: :user, content: "Hello"},
             %HyperLLM.Chat.Message{role: :user, content: "World"}
           ]
  end
end
