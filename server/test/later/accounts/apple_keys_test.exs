defmodule Later.Accounts.AppleKeysTest do
  use ExUnit.Case, async: true

  alias Later.Accounts.AppleKeys

  test "returns the keys from Apple's JWKS" do
    Req.Test.stub(AppleKeys, fn conn ->
      assert conn.host == "appleid.apple.com"
      assert conn.request_path == "/auth/keys"
      Req.Test.json(conn, %{"keys" => [%{"kid" => "abc", "kty" => "RSA"}]})
    end)

    assert {:ok, [%{"kid" => "abc"}]} = AppleKeys.fetch_keys()
  end

  test "reports Apple's keys as unavailable when the fetch fails" do
    Req.Test.stub(AppleKeys, &Plug.Conn.send_resp(&1, 500, "oops"))
    assert {:error, :apple_keys_unavailable} = AppleKeys.fetch_keys()
  end
end
