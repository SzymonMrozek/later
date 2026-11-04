# Later API

The JSON API the iOS app calls. Keys are snake_case; the app converts them. Every path is under
the server's base URL, `http://localhost:$PORT` for a worktree (`mise run server:dev`).

## Sessions

Both endpoints return the same session. The app stores it on the device and sends the token as
`Authorization: Bearer <token>` on later requests.

```json
{
  "token": "opaque string",
  "account": { "id": "uuid", "kind": "guest", "email": null }
}
```

`kind` is `guest` or `apple`; `email` is set only for an Apple account whose owner shared it.

### `POST /api/sessions/guest`

Try without an account. The app generates `device_id` once per install and keeps it in the
keychain.

```json
{ "device_id": "uuid" }
```

Returns the guest account for that device, creating it on the first call. Calling again with the
same `device_id` returns the same account.

### `POST /api/sessions/apple`

Sign in with Apple.

```json
{
  "device_id": "uuid",
  "identity_token": "JWT from Apple",
  "authorization_code": "one-time code from Apple",
  "given_name": "Ada",
  "family_name": "Lovelace",
  "email": "ada@example.com"
}
```

`given_name`, `family_name` and `email` are sent only on the first sign-in, and only if the person
shared them. The server verifies `identity_token` against Apple's keys and this app's bundle ID
(`dev.mrozek.later`), and identifies the person by its `sub`. If `device_id` has a guest account,
the Apple account takes over its library.

## Errors

| Status | Meaning | The app shows |
| --- | --- | --- |
| 2xx | Success | |
| 401 | Apple's token didn't verify | "Couldn't sign you in" |
| 422 | Missing or invalid fields | "Couldn't sign you in" |
| No response | Server unreachable | "You're offline" |
