defmodule LaterWeb.FallbackController do
  @moduledoc """
  Turns context errors into the statuses `docs/api.md` lists.
  """
  use LaterWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: LaterWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :invalid_identity_token}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: LaterWeb.ErrorJSON)
    |> render(:"401")
  end

  def call(conn, {:error, :apple_keys_unavailable}) do
    conn
    |> put_status(:service_unavailable)
    |> put_view(json: LaterWeb.ErrorJSON)
    |> render(:"503")
  end
end
