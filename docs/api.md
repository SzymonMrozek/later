# Later API

The JSON API the iOS app calls. Keys are snake_case; the app converts them. Every path is under
the server's base URL, `http://localhost:$PORT` for a worktree (`mise run server:dev`).

## Sessions

Every session endpoint returns the same session. The app stores it on the device and sends the
access token as `Authorization: Bearer <access_token>` on later requests.

```json
{
  "access_token": "opaque string",
  "refresh_token": "opaque string",
  "expires_at": "2026-11-04T18:00:00Z",
  "account": { "id": "uuid", "kind": "guest", "email": null }
}
```

`kind` is `guest` or `apple`; `email` is set only for an Apple account whose owner shared it.

The access token works for an hour, until `expires_at` (ISO 8601, UTC). Before then, or after a
request comes back 401, the app trades the refresh token for a new session with
`POST /api/sessions/refresh`. A refresh token works once and expires after 90 days unused; if
refreshing fails with 401, the app signs out.

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
the Apple account takes over its library. For a new person the guest account becomes the Apple
account, so its sessions keep working; if the person already has an Apple account, the guest is
merged into it and its sessions end. Either way a later guest sign-in with that `device_id` creates
a new guest. Apple's `email` claim wins over the `email` the app sends.

### `POST /api/sessions/refresh`

Trade a refresh token for a new session.

```json
{ "refresh_token": "opaque string" }
```

Returns the session with a new access token, refresh token and `expires_at`. The old refresh token
and access token stop working. An unknown, already used or expired refresh token gets 401.

## Errors

| Status | Meaning | The app shows |
| --- | --- | --- |
| 2xx | Success | |
| 401 | Apple's token didn't verify, or the refresh token is no good | "Couldn't sign you in"; after a failed refresh, the Welcome screen |
| 401 on any other request | The access token expired or isn't known | Nothing; the app refreshes and retries once |
| 422 | Missing or invalid fields | "Couldn't sign you in" |
| 503 | Apple's keys couldn't be fetched | "Couldn't sign you in" |
| No response | Server unreachable | "You're offline" |

Error bodies: 422 is `{"errors": {"device_id": ["can't be blank"]}}`; 401 and 503 are
`{"errors": {"detail": "Unauthorized"}}` with the status's own message.
