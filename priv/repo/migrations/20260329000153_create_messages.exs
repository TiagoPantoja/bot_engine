defmodule BotEngine.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :room_id, :string, null: false
      add :body, :text, null: false

      timestamps()
    end

    create index(:messages, [:room_id])
  end
end
