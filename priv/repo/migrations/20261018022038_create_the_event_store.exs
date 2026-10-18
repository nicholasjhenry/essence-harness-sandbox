defmodule Shortener.Repo.Migrations.CreateTheEventStore do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :position, :integer, primary_key: true, autoincrement: true
      add :type, :text, null: false
      add :data, :text, null: false
      add :appended_at, :utc_datetime_usec, null: false
    end

    create index(:events, [:type, :position])

    create table(:event_tags, primary_key: false) do
      add :tag, :text, null: false, primary_key: true

      add :position, references(:events, column: :position, on_delete: :delete_all),
        null: false,
        primary_key: true
    end
  end
end
