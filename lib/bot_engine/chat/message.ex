defmodule BotEngine.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :room_id, :string
    field :body, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:room_id, :body])
    |> validate_required([:room_id, :body])
    |> validate_length(:body, min: 1, max: 2000)
  end
end
