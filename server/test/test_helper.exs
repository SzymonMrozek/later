ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Later.Repo, :manual)

# Generate the test signing keys once, before async tests race to create them.
Later.AppleIdentityFixtures.private_key()
Later.AppleIdentityFixtures.other_private_key()
