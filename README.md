# HyperLLM

[![CI](https://github.com/cgarvis/hyper_llm/actions/workflows/elixir.yml/badge.svg)](https://github.com/cgarvis/hyper_llm/actions/workflows/elixir.yml)
[![License](https://img.shields.io/hexpm/l/hyper_llm.svg)](https://github.com/cgarvis/hyper_llm/blob/main/LICENSE.md)
[![Version](https://img.shields.io/hexpm/v/hyper_llm.svg)](https://hex.pm/packages/hyper_llm)
[![Hex Docs](https://img.shields.io/badge/documentation-gray.svg)](https://hexdocs.pm/hyper_llm)

Call all LLM APIs using the OpenAI format.

## Installation

Add `hyper_llm` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hyper_llm, "~> 0.6.0"}
  ]
end
```

## Configurations

```elixir
config :hyper_llm,
  openai: [
    api_key: "sk-..."
  ],
  anthropic: [
    api_key: "sk-..."
  ],
  # ...
```

## Usage

The `HyperLLM.Conversation` module is used to start a new conversation of the LLM provider of your choices.

```elixir
HyperLLM.Conversation.start(model: "openai/gpt-4o-mini")
|> HyperLLM.Conversation.append(:developer, "You are a helpful assistant.")
|> HyperLLM.Conversation.append("Spell strawbeerry")
|> HyperLLM.Conversation.run!()
#=> %HyperLLM.Conversation{
  model: "openai/gpt-4o-mini",
  thread: [
    %{role: "developer", content: "You are a helpful assistant."},
    %{role: "user", content: "Spell strawbeerry"},
    %{role: "assistant", content: "Strawberry. 🍓"}
  ]
}
```

Under the hood, the `HyperLLM.Conversation` module is using `HyperLLM.Chat.completion/3` to receive a OpenAI compatible response.

```elixir
HyperLLM.Chat.completion("openai/gpt-4o-mini", [
  %{role: "user", content: "Spell \"strawberry\""}
])
#=> {:ok, %{
  "id" => "chatcmpl-1234567890",
  "object" => "chat.completion",
  "created" => 1717753987,
  "choices" => [
    %{
      "message" => %{
        "role" => "assistant",
        "content" => "Strawberry. 🍓"
      },
      "index" => 0,
      "finish_reason" => "stop"
    }
  ]
}}
```

```elixir
HyperLLM.Chat.completion("anthropic/claude-3-5-sonnet-20240620", [
  %{role: "user", content: "Spell \"strawberry\""}
])
#=> {:ok, %{
  "id" => "chatcmpl-1234567890",
  "object" => "chat.completion",
  "created" => 1717753987,
  "choices" => [
    %{
      "message" => %{
        "role" => "assistant",
        "content" => "Strawberry. 🍓"
      },
      "index" => 0,
      "finish_reason" => "stop"
    }
  ]
}}
```

If you are using Phoenix, you can use the `HyperLLM.Conversation` module in your LiveView.

```elixir
defmodule ChatLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <div>
      <dl>
        <%= for message <- @chat.messages do %>
          <dt><%= message.role %></dt>
          <dd><%= message.content %></dd>
        <% end %>
      </dl>
    </div>
    """
  end

  def mount(params, session, socket) do
    {:ok,
    socket
    |> assign(conv: HyperLLM.Conversation.start(model: "openai/gpt-4o-mini"))}
  end

  def handle_event("send_message", %{"message" => message}, socket) do
    conv = HyperLLM.Conversation.append(socket.assigns.conv, :user, message)

    send(self(), :chat_completion)
    
    {:noreply, socket |> assign(conv: conv)}
  end

  def handle_info(:chat_completion, socket) do
    with {:ok, conv} <- HyperLLM.Conversation.run(socket.assigns.conv) do
      {:noreply, socket |> assign(conv: conv)}
    end
  end
end
```

## Provider Support

| Provider           | Completion | Streaming | 
| ------------------ | ---------- | --------- |
| Anthropic          | ✅         | ❌        |
| Cloudflare         | ✅         | ❌        |
| Groq               | ✅         | ❌        |
| LlamaCPP           | ✅         | ❌        |
| Mistral            | ✅         | ❌        |
| Ollama             | ✅         | ❌        |
| OpenAI             | ✅         | ❌        |
| xAI                | ✅         | ❌        |
| Azure              | ❌         | ❌        |
| AWS SageMaker      | ❌         | ❌        |
| AWS Bedrock        | ❌         | ❌        |
| Cohere             | ❌         | ❌        |
| DeepSeek           | ❌         | ❌        |
| Empower            | ❌         | ❌        |
| Google - Vertex AI | ❌         | ❌        |
| Google - Palm      | ❌         | ❌        |
| Google AI Studio   | ❌         | ❌        |
| Hugging Face       | ❌         | ❌        |
| Perplexity         | ❌         | ❌        |
| Replicate          | ❌         | ❌        |
| TogetherAI         | ❌         | ❌        |
| Vertex AI          | ❌         | ❌        |