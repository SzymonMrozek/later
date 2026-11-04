defmodule Later.Accounts.Account do
  @moduledoc """
  A person's account: an anonymous guest tied to one install, or an Apple account.
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "accounts" do
    field :kind, Ecto.Enum, values: [:guest, :apple]
    field :device_id, Ecto.UUID
    field :apple_sub, :string
    field :email, :string
    field :given_name, :string
    field :family_name, :string

    timestamps(type: :utc_datetime)
  end

  @doc """
  Turns an account into an Apple account, keeping profile fields Apple didn't send again.
  """
  def apple_changeset(account, sub, profile) do
    account
    |> change(kind: :apple, apple_sub: sub, device_id: nil)
    |> put_present(profile, [:email, :given_name, :family_name])
    |> unique_constraint(:apple_sub)
  end

  defp put_present(changeset, profile, fields) do
    Enum.reduce(fields, changeset, fn field, changeset ->
      case Map.get(profile, field) do
        nil -> changeset
        value -> put_change(changeset, field, value)
      end
    end)
  end
end
