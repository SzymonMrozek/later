defmodule Later.AppleKeysStub do
  @moduledoc """
  Stands in for Apple's keys in tests: serves the public half of `Later.AppleIdentityFixtures`'
  key pair, or fails after `unavailable/0` in the calling test process.
  """
  @behaviour Later.Accounts.AppleKeys

  @impl true
  def fetch_keys do
    if Process.get(__MODULE__) == :unavailable,
      do: {:error, :apple_keys_unavailable},
      else: {:ok, [Later.AppleIdentityFixtures.public_jwk()]}
  end

  def unavailable, do: Process.put(__MODULE__, :unavailable)
end
