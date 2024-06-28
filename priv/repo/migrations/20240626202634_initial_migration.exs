defmodule TeamAsh.Repo.Migrations.InitialMigration do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:engagements, primary_key: false) do
      add :id, :bigserial, null: false, primary_key: true
      add :name, :text, null: false
      add :starts_on, :date
      add :ends_on, :date
      add :client_id, :bigint
    end

    create table(:clients, primary_key: false) do
      add :id, :bigserial, null: false, primary_key: true
    end

    alter table(:engagements) do
      modify :client_id,
             references(:clients,
               column: :id,
               name: "engagements_client_id_fkey",
               type: :bigint,
               prefix: "public"
             )
    end

    alter table(:clients) do
      add :name, :text, null: false
      add :owner, :text
      add :source, :text
      add :closed_on, :date
    end
  end

  def down do
    alter table(:clients) do
      remove :closed_on
      remove :source
      remove :owner
      remove :name
    end

    drop constraint(:engagements, "engagements_client_id_fkey")

    alter table(:engagements) do
      modify :client_id, :bigint
    end

    drop table(:clients)

    drop table(:engagements)
  end
end
