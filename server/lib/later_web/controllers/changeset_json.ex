defmodule LaterWeb.ChangesetJSON do
  @doc """
  Renders changeset errors as `{"errors": {"field": ["message"]}}`.
  """
  def error(%{changeset: changeset}) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  defp translate_error({message, opts}) do
    Regex.replace(~r"%{(\w+)}", message, fn _match, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
