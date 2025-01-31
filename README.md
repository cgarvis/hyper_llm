# HyperLLM

[![CI](https://github.com/cgarvis/hyper_llm/actions/workflows/elixir.yml/badge.svg)](https://github.com/cgarvis/hyper_llm/actions/workflows/elixir.yml)
[![License](https://img.shields.io/hexpm/l/hyper_llm.svg)](https://github.com/cgarvis/hyper_llm/blob/main/LICENSE.md)
[![Version](https://img.shields.io/hexpm/v/hyper_llm.svg)](https://hex.pm/packages/hyper_llm)
[![Hex Docs](https://img.shields.io/badge/documentation-gray.svg)](https://hexdocs.pm/hyper_llm)

Call all LLM APIs using the OpenAI format

## Installation

Add `hyper_llm` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hyper_llm, "~> 0.0.1"}
  ]
end
```

## Usage

```elixir

HyperLLM.Chat.start(model: "gpt-4o-mini")
|> HyperLLM.Chat.append(:developer, "You are a helpful assistant.")
|> HyperLLM.Chat.append(:user, "Spell \"strawberry\"")
|> HyperLLM.Chat.completion()
#=> {:ok, "Strawberry. 🍓"}
```

If you are using Phoenix, you can use the `HyperLLM.Chat` module in your LiveView.

```elixir
defmodule ChatLive do
  use Phoenix.LiveView

  def mount(params, session, socket) do
    {:ok,
    socket
    |> assign(chat: HyperLLM.Chat.start(model: "gpt-4o-mini"))}
  end

  def handle_event("send_message", %{"message" => message}, socket) do
    chat = HyperLLM.Chat.append(socket.assigns.chat, message)

    send(self(), :chat_completion)
    
    {:noreply, socket |> assign(chat: chat)}
  end

  def handle_info(:chat_completion, socket) do
    with {:ok, response} <- HyperLLM.Chat.completion(socket.assigns.chat) do
      chat = HyperLLM.Chat.append(socket.assigns.chat, response)
      {:noreply, socket |> assign(chat: chat)}
    end
  end
end
```

## Providers

- [x] OpenAI
- [ ] Azure
- [x] Anthropic
- [ ] AWS SageMaker
- [ ] AWS Bedrock
- [ ] Google - Vertex AI
- [ ] Google - Palm
- [ ] Mistral AI
- [ ] CloudFlare AI Workers
- [ ] Cohere
- [ ] Groq
- [ ] Ollama
- [ ] Vertex AI