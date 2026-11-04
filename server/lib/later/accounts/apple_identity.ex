defmodule Later.Accounts.AppleIdentity do
  @moduledoc """
  Verifies Sign in with Apple identity tokens: an RS256 JWT signed with one of Apple's keys,
  issued by Apple for this app's bundle ID.
  """

  @issuer "https://appleid.apple.com"

  @doc """
  Returns the token's claims, `{:error, :invalid_identity_token}` when it doesn't verify, or
  `{:error, :apple_keys_unavailable}` when Apple's keys can't be fetched.
  """
  def verify(token) when is_binary(token) do
    with [header_part, claims_part, signature_part] <- String.split(token, "."),
         {:ok, %{"alg" => "RS256", "kid" => kid}} <- decode_json(header_part),
         {:ok, claims} <- decode_json(claims_part),
         {:ok, signature} <- Base.url_decode64(signature_part, padding: false),
         :ok <- validate_claims(claims),
         {:ok, key} <- fetch_key(kid),
         true <- :public_key.verify("#{header_part}.#{claims_part}", :sha256, signature, key) do
      {:ok, claims}
    else
      {:error, :apple_keys_unavailable} = error -> error
      _invalid -> {:error, :invalid_identity_token}
    end
  end

  defp decode_json(part) do
    with {:ok, json} <- Base.url_decode64(part, padding: false),
         {:ok, %{} = map} <- Jason.decode(json) do
      {:ok, map}
    end
  end

  defp validate_claims(%{"iss" => @issuer, "aud" => aud, "exp" => exp, "sub" => sub})
       when is_integer(exp) and is_binary(sub) and sub != "" do
    cond do
      aud != Application.fetch_env!(:later, :apple_bundle_id) -> {:error, :wrong_audience}
      exp <= System.os_time(:second) -> {:error, :expired}
      true -> :ok
    end
  end

  defp validate_claims(_claims), do: {:error, :invalid_claims}

  defp fetch_key(kid) do
    with {:ok, keys} <-
           Application.get_env(:later, :apple_keys, Later.Accounts.AppleKeys).fetch_keys(),
         %{"n" => n, "e" => e} <- Enum.find(keys, &match?(%{"kid" => ^kid, "kty" => "RSA"}, &1)),
         {:ok, n} <- Base.url_decode64(n, padding: false),
         {:ok, e} <- Base.url_decode64(e, padding: false) do
      {:ok, {:RSAPublicKey, :binary.decode_unsigned(n), :binary.decode_unsigned(e)}}
    else
      {:error, _reason} -> {:error, :apple_keys_unavailable}
      _no_key -> {:error, :unknown_key}
    end
  end
end
