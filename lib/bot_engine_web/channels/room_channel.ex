defmodule BotEngineWeb.RoomChannel do
  use BotEngineWeb, :channel
  require Logger

  alias BotEngine.Chat

  @doc """
  Autoriza a entrada na sala.
  Aplicando YAGNI: Permitimos a entrada em qualquer "room:*" por agora.
  """
  @impl true
  def join("room:" <> room_id, payload, socket) do
    Logger.info("Cliente juntou-se à sala: #{room_id} com payload: #{inspect(payload)}")

    socket = assign(socket, :room_id, room_id)
    {:ok, socket}
  end

  @impl true
  def handle_in("new_message", %{"body" => body}, socket) do
    room_id = socket.assigns.room_id

    case Chat.create_message(%{room_id: room_id, body: body}) do
      {:ok, message} ->
        broadcast!(socket, "new_message", %{
          id: message.id,
          body: message.body,
          room_id: message.room_id
        })
        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: format_errors(changeset)}}, socket}
    end
  end

  @impl true
  def handle_in("trigger_action", %{"action" => action, "payload" => payload}, socket) do
    room_id = socket.assigns.room_id

    case Chat.process_action(action, payload, room_id) do
      {:ok, result} ->
        broadcast!(socket, "action_triggered", result)
        {:reply, {:ok, result}, socket}

      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end

  @impl true
  def handle_in(unknown_event, payload, socket) do
    Logger.warning("Evento desconhecido recebido: #{unknown_event} - #{inspect(payload)}")
    {:reply, {:error, %{reason: "unsupported_event"}}, socket}
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
