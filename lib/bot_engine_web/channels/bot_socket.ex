defmodule BotEngineWeb.BotSocket do
  use Phoenix.Socket

  # Mapeia os tópicos (salas) para o Channel responsável.
  # Tudo o que começar por "room:" será gerido pelo RoomChannel.
  channel "room:*", BotEngineWeb.RoomChannel

  @doc """
  Lida com a ligação inicial.
  Aqui aplicamos KISS: por agora, aceitamos qualquer ligação sem autenticação complexa.
  Num cenário de produção real, validaríamos um token JWT aqui.
  """
  @impl true
  def connect(_params, socket, _connect_info) do
    # Podemos atribuir dados ao socket que duram por toda a ligação
    # Ex: socket = assign(socket, :bot_id, params["token"])
    {:ok, socket}
  end

  @doc """
  Identifica unicamente cada ligação.
  Útil se precisarmos de "expulsar" (disconnect) um bot ou utilizador específico.
  """
  @impl true
  def id(_socket), do: nil
end
