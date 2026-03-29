defmodule BotEngine.Webhooks.Worker do
  @moduledoc """
  Worker responsável por despachar as ações em background via HTTP.
  Garante retentativas automáticas (Exponential Backoff) em caso de falha.
  """
  use Oban.Worker,
    queue: :webhooks,
    max_attempts: 5 # Tentará 5 vezes com espaçamento exponencial antes de desistir (Dead Letter)

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"action" => action, "payload" => payload, "room_id" => room_id}}) do
    Logger.info("Processando webhook em background para ação: #{action} na sala #{room_id}")


    target_url = "https://httpbin.org/post"

    body = %{
      event: action,
      data: payload,
      source_room: room_id
    }

    case Req.post(target_url, json: body) do
      {:ok, %Req.Response{status: status}} when status in 200..299 ->
        Logger.info("Webhook disparado com sucesso! (Status: #{status})")
        :ok

      {:ok, %Req.Response{status: status}} ->
        Logger.error("A API de destino retornou erro HTTP: #{status}")
        {:error, "HTTP Error #{status}"}

      {:error, exception} ->
        Logger.error("Falha de rede ao tentar conectar: #{inspect(exception)}")
        {:error, exception}
    end
  end
end
