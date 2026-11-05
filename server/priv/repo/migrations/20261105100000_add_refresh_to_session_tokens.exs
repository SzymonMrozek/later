defmodule Later.Repo.Migrations.AddRefreshToSessionTokens do
  use Ecto.Migration

  # Sessions issued before this have no refresh token and can't be renewed, so they end here and
  # their devices sign in again.
  def up do
    execute "DELETE FROM session_tokens"

    drop unique_index(:session_tokens, [:token_hash])

    alter table(:session_tokens) do
      remove :token_hash

      # SHA-256 of each token; the tokens themselves are never stored. Refreshing replaces both.
      add :access_token_hash, :binary, null: false
      add :access_expires_at, :utc_datetime, null: false
      add :refresh_token_hash, :binary, null: false
      add :refresh_expires_at, :utc_datetime, null: false
      add :updated_at, :utc_datetime, null: false
    end

    create unique_index(:session_tokens, [:access_token_hash])
    create unique_index(:session_tokens, [:refresh_token_hash])
  end

  def down do
    execute "DELETE FROM session_tokens"

    drop unique_index(:session_tokens, [:refresh_token_hash])
    drop unique_index(:session_tokens, [:access_token_hash])

    alter table(:session_tokens) do
      remove :access_token_hash
      remove :access_expires_at
      remove :refresh_token_hash
      remove :refresh_expires_at
      remove :updated_at
      add :token_hash, :binary, null: false
    end

    create unique_index(:session_tokens, [:token_hash])
  end
end
