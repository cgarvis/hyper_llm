defmodule HyperLLM.Chat do
  @derive Jason.Encoder

  @moduledoc """
  HypperLLM.Chat is a single interface for interacting with LLM providers.
  The interface uses the OpenAI chat completion API. https://platform.openai.com/docs/api-reference/chat

  ## Example

  A Liveview that sends messages to the chat and updates the chat with the response.

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
  """

  @type t :: %__MODULE__{}
  @type config :: [Keyword.t()]

  @enforce_keys [:messages, :provider, :config]
  defstruct [:messages, :provider, :config]

  defmodule Message do
    @derive Jason.Encoder

    @moduledoc false

    @type t :: %__MODULE__{}

    @enforce_keys [:role, :content]
    defstruct [:role, :content]
  end

  @doc """
  Start a new chat.

  ## Example

      iex> HyperLLM.Chat.start(model: "gpt-4o-mini")
      %HyperLLM.Chat{
        messages: [],
        provider: HyperLLM.Provider.OpenAI, 
        config: [model: "gpt-4o-mini"]
      }
  """
  @spec start(config()) :: t()
  def start(config \\ []) when is_list(config) do
    model = Keyword.fetch!(config, :model)

    provider = HyperLLM.Models.provider_for!(model)

    %__MODULE__{
      messages: [],
      provider: provider,
      config: config
    }
  end

  @doc """
  Append a message to the chat with the role.

  ## Example

      iex> chat = HyperLLM.Chat.start(model: "gpt-4o-mini")
      iex> HyperLLM.Chat.append(chat, :developer, "You are a helpful assistant.")
      %HyperLLM.Chat{
        messages: [
          %HyperLLM.Chat.Message{
            role: :developer,
            content: "You are a helpful assistant."
          }
        ],
        provider: HyperLLM.Provider.OpenAI,
        config: [model: "gpt-4o-mini"]
      }
  """
  @spec append(t(), atom(), binary()) :: t()
  def append(%__MODULE__{} = chat, role, content) when is_atom(role) do
    append(chat, %Message{role: role, content: content})
  end

  @doc """
  Append a message to the chat as a user.

      iex> chat = HyperLLM.Chat.start(model: "gpt-4o-mini")
      iex> HyperLLM.Chat.append(chat, "Hello")
      %HyperLLM.Chat{
        messages: [
          %HyperLLM.Chat.Message{role: :user, content: "Hello"}
        ], 
        provider: HyperLLM.Provider.OpenAI,
        config: [model: "gpt-4o-mini"]
      }

  You can also append a list of messages to the chat.

      iex> chat = HyperLLM.Chat.start(model: "gpt-4o-mini")
      iex> HyperLLM.Chat.append(chat, ["Hello", "World"])
      %HyperLLM.Chat{
        messages: [
          %HyperLLM.Chat.Message{role: :user, content: "Hello"},
          %HyperLLM.Chat.Message{role: :user, content: "World"}
        ],
        provider: HyperLLM.Provider.OpenAI,
        config: [model: "gpt-4o-mini"]
      }
  """
  @spec append(t(), Message.t()) :: t()
  def append(%__MODULE__{} = chat, message) when is_binary(message) do
    append(chat, %Message{role: :user, content: message})
  end

  @spec append(t(), [Message.t()]) :: t()
  def append(%__MODULE__{} = chat, messages) when is_list(messages) do
    Enum.reduce(messages, chat, fn message, acc ->
      append(acc, message)
    end)
  end

  def append(%__MODULE__{} = chat, message) do
    %{chat | messages: chat.messages ++ [message]}
  end

  @spec completion(t(), config()) :: binary()
  def completion(%__MODULE__{} = chat, config \\ []) do
    chat.provider.completion(chat.messages, Keyword.merge(chat.config, config))
  end
end

defimpl String.Chars, for: HyperLLM.Chat do
  def to_string(chat) do
    Jason.encode!(chat)
  end
end

defimpl String.Chars, for: HyperLLM.Chat.Message do
  def to_string(message) do
    Jason.encode!(message)
  end
end
