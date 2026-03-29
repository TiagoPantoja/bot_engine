defmodule BotEngine.Chat do
  @moduledoc """
  Bounded Context responsável pelas mensagens e orquestração de ações do chat.
  """
  alias BotEngine.Repo
  alias BotEngine.Chat.Message

  @doc """
  Tenta salvar uma nova mensagem no banco de dados.
  Retorna {:ok, %Message{}} ou {:error, %Ecto.Changeset{}}.
  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Processa uma ação solicitada pelo cliente (ex: disparar webhook).
  Aqui preparamos o terreno para a integração com o Oban.
  """
  def process_action(action, payload, room_id) do
    args = %{
      "action" => action,
      "payload" => payload,
      "room_id" => room_id
    }

    case args |> Worker.new() |> Oban.insert() do
      {:ok, _job} ->
        {:ok, %{action: action, payload: payload, room_id: room_id, status: "queued_for_delivery"}}

      {:error, _changeset} ->
        {:error, "failed_to_queue_action"}
    end
  end
end
