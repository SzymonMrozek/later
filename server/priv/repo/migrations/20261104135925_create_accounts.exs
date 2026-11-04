defmodule Later.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :kind, :string, null: false
      # Set only on guest accounts; cleared when an Apple account takes the guest over.
      add :device_id, :uuid
      add :apple_sub, :string
      add :email, :string
      add :given_name, :string
      add :family_name, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:accounts, [:device_id])
    create unique_index(:accounts, [:apple_sub])

    create table(:session_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :account_id, references(:accounts, type: :binary_id, on_delete: :delete_all),
        null: false

      # SHA-256 of the bearer token; the token itself is never stored.
      add :token_hash, :binary, null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create unique_index(:session_tokens, [:token_hash])
    create index(:session_tokens, [:account_id])
  end
end
