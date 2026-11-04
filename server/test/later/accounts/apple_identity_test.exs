defmodule Later.Accounts.AppleIdentityTest do
  use ExUnit.Case, async: true

  import Later.AppleIdentityFixtures

  alias Later.Accounts.AppleIdentity

  test "returns the claims of a token Apple signed for this app" do
    token = identity_token(%{"sub" => "apple-ada", "email" => "ada@example.com"})

    assert {:ok, %{"sub" => "apple-ada", "email" => "ada@example.com"}} =
             AppleIdentity.verify(token)
  end

  test "rejects a token signed with a key Apple doesn't publish" do
    token = identity_token(%{}, key: other_private_key())
    assert {:error, :invalid_identity_token} = AppleIdentity.verify(token)
  end

  test "rejects a tampered payload" do
    [header, _payload, signature] = String.split(identity_token(), ".")
    [_header, payload, _signature] = String.split(identity_token(%{"sub" => "someone-else"}), ".")

    assert {:error, :invalid_identity_token} =
             AppleIdentity.verify("#{header}.#{payload}.#{signature}")
  end

  for {name, claims} <- [
        {"another issuer", %{"iss" => "https://example.com"}},
        {"another audience", %{"aud" => "com.example.other"}},
        {"an expired token", %{"exp" => System.os_time(:second) - 1}},
        {"a token without sub", %{"sub" => nil}}
      ] do
    test "rejects #{name}" do
      token = identity_token(unquote(Macro.escape(claims)))
      assert {:error, :invalid_identity_token} = AppleIdentity.verify(token)
    end
  end

  test "rejects a token that isn't RS256" do
    [_header, payload, signature] = String.split(identity_token(), ".")
    header = Base.url_encode64(~s({"alg":"none","kid":"test-key"}), padding: false)

    assert {:error, :invalid_identity_token} =
             AppleIdentity.verify("#{header}.#{payload}.#{signature}")
  end

  test "rejects malformed tokens" do
    for token <- ["", "a.b", "a.b.c", "a.b.c.d"] do
      assert {:error, :invalid_identity_token} = AppleIdentity.verify(token)
    end
  end
end
