defmodule HyperLLM.Conversation do
  @derive Jason.Encoder

  @moduledoc """
  HyperLLM.Conversation handles the lifecycle of a conversation, including starting, appending messages, and running the conversation.

   ## Example

  A Liveview that sends messages to the chat and updates the chat with the response.

      defmodule ChatLive do
        use Phoenix.LiveView

        def mount(params, session, socket) do
          {:ok,
          socket
          |> assign(conv: HyperLLM.Conversation.start(model: "openai/gpt-4o-mini"))}
        end

        def handle_event("send_message", %{"message" => message}, socket) do
          conv = HyperLLM.Conversation.append(socket.assigns.conv, message)

          send(self(), :chat_completion)

          {:noreply, socket |> assign(conv: conv)}
        end

        def handle_info(:chat_completion, socket) do
          with {:ok, conv} <- HyperLLM.Conversation.run(socket.assigns.conv) do
            {:noreply, socket |> assign(conv: conv)}
          end
        end
      end
  """

  @type t :: %__MODULE__{}
  @type model_config :: [Keyword.t()]

  @enforce_keys [:thread, :model]
  defstruct [:thread, :model]

  @doc """
  Start a new conversation.

  ## Example

      iex> HyperLLM.Conversation.start(model: "openai/gpt-4o-mini")
      %HyperLLM.Conversation{
        thread: [],
        model: %HyperLLM.Model{
          provider: HyperLLM.Provider.OpenAI,
          model: "gpt-4o-mini",
          config: []
        }
      }
  """
  @spec start(model_config()) :: t()
  def start(model_config \\ []) when is_list(model_config) do
    %__MODULE__{
      thread: [],
      model: HyperLLM.Model.new!(model_config)
    }
  end

  @doc """
  Append a message to the conversation.

  ## Example

      iex> HyperLLM.Conversation.start(model: "openai/gpt-4o-mini") |> HyperLLM.Conversation.append(:user, "Hello")
      %HyperLLM.Conversation{
        thread: [%{role: :user, content: "Hello"}],
        model: %HyperLLM.Model{
          provider: HyperLLM.Provider.OpenAI,
          model: "gpt-4o-mini",
          config: []
        }
      }
  """
  @spec append(t(), atom(), binary()) :: t()
  def append(%__MODULE__{} = conv, role, content) when is_atom(role) do
    append(conv, %{role: role, content: content})
  end

  @spec append(t(), list()) :: t()
  def append(%__MODULE__{} = conv, messages) when is_list(messages) do
    Enum.reduce(messages, conv, &append(&2, &1))
  end

  @spec append(t(), String.t()) :: t()
  def append(%__MODULE__{} = conv, message) when is_binary(message) do
    append(conv, %{role: :user, content: message})
  end

  @spec append(t(), map()) :: t()
  def append(%__MODULE__{} = conv, message) when is_map(message) do
    %{conv | thread: conv.thread ++ [message]}
  end

  @doc """
  Run the conversation to get a response.

  ## Example

      iex> HyperLLM.Conversation.start(model: "openai/gpt-4o-mini") |> HyperLLM.Conversation.append(:user, "Hello") |> HyperLLM.Conversation.run()
      {:ok, %HyperLLM.Conversation{
        thread: [%{role: :user, content: "Hello"}, %{role: :assistant, content: "Hello, how can I help you today?"}],
        model: "gpt-4o-mini"
      }}
  """
  @spec run(t()) :: {:ok, binary()} | {:error, binary()}
  def run(%__MODULE__{} = conv) do
    with {:ok, response} <- HyperLLM.Chat.completion(conv.model, conv.thread, []),
         choice when not is_nil(choice) <- hd(response["choices"]),
         message when not is_nil(message) <- choice["message"] do
      message = %{role: String.to_atom(message["role"]), content: message["content"]}
      {:ok, %{conv | thread: conv.thread ++ [message]}}
    end
  end

  @spec run!(t()) :: t()
  def run!(%__MODULE__{} = conv) do
    case run(conv) do
      {:ok, conv} ->
        conv

      {:error, error} ->
        raise error
    end
  end
end
