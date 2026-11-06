defmodule Later.AppleIdentityFixtures do
  @moduledoc """
  Signs identity tokens the way Apple does, with a key pair generated once per test run.
  """

  @kid "test-key"

  @doc """
  Returns an RS256 identity token for `claims` merged over valid Apple claims.

  Pass `key: other_private_key()` to sign with a key Apple doesn't publish.
  """
  def identity_token(claims \\ %{}, opts \\ []) do
    claims =
      Map.merge(
        %{
          "iss" => "https://appleid.apple.com",
          "aud" => "com.later",
          "sub" => "001234.#{System.unique_integer([:positive])}",
          "iat" => System.os_time(:second),
          "exp" => System.os_time(:second) + 600
        },
        claims
      )

    header = encode(%{"alg" => "RS256", "kid" => @kid})
    payload = encode(claims)
    key = Keyword.get_lazy(opts, :key, &private_key/0)
    signature = :public_key.sign("#{header}.#{payload}", :sha256, key)

    "#{header}.#{payload}.#{Base.url_encode64(signature, padding: false)}"
  end

  def public_jwk do
    {:RSAPrivateKey, _version, n, e, _d, _p, _q, _dp, _dq, _qi, _other} = private_key()

    %{
      "kty" => "RSA",
      "kid" => @kid,
      "use" => "sig",
      "alg" => "RS256",
      "n" => n |> :binary.encode_unsigned() |> Base.url_encode64(padding: false),
      "e" => e |> :binary.encode_unsigned() |> Base.url_encode64(padding: false)
    }
  end

  def private_key, do: cached_key(:apple)

  def other_private_key, do: cached_key(:other)

  defp cached_key(name) do
    key = {__MODULE__, name}

    case :persistent_term.get(key, nil) do
      nil ->
        private_key = :public_key.generate_key({:rsa, 2048, 65_537})
        :persistent_term.put(key, private_key)
        private_key

      private_key ->
        private_key
    end
  end

  defp encode(map), do: map |> Jason.encode!() |> Base.url_encode64(padding: false)
end
