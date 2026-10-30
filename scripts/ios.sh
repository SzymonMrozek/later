#!/usr/bin/env bash
# Builds, tests and runs the iOS app on this worktree's own simulator (pitcrew worktree-simulator).
#   scripts/ios.sh build|test|run [--udid UDID]
#   scripts/ios.sh destinations    JSON for local-review's Run… dialog
set -euo pipefail
cd "$(dirname "$0")/.."

action="${1:?usage: scripts/ios.sh build|test|run|destinations [--udid UDID]}"
shift
udid=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --udid) udid="$2"; shift 2 ;;
    *) echo "error: unknown argument: $1" >&2; exit 2 ;;
  esac
done

bundle_id="dev.mrozek.later"
derived_data=".build/ios"
worktree_simulator="tools/pitcrew/worktree-simulator/worktree_simulator.py"

# Reuses the device recorded for this worktree; the primary worktree gets one on first use.
worktree_udid() {
  python3 "$worktree_simulator" create --name "Later $(git branch --show-current | tr '/' '-')"
}

# A freshly created device can't launch apps until its first boot finishes.
boot() {
  xcrun simctl bootstatus "$udid" -b >/dev/null
}

xcodebuild_app() {
  (cd ios && tuist generate --no-open >/dev/null)
  xcodebuild "$1" -quiet \
    -workspace ios/Later.xcworkspace \
    -scheme Later \
    -destination "platform=iOS Simulator,id=$udid" \
    -derivedDataPath "$derived_data"
}

case "$action" in
  destinations)
    WORKTREE_UDID="$(worktree_udid)" python3 - <<'PY'
import json, os, subprocess

own = os.environ["WORKTREE_UDID"]
devices = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "--json"]))["devices"]
found = []
for runtime, entries in devices.items():
    if ".iOS-" not in runtime:
        continue
    version = runtime.rsplit(".iOS-", 1)[1].replace("-", ".")
    for device in entries:
        detail = f"iOS {version}" + (" · this worktree" if device["udid"] == own else "")
        found.append({"id": device["udid"], "name": device["name"], "kind": "Simulator", "detail": detail})
found.sort(key=lambda item: item["id"] != own)
print(json.dumps(found))
PY
    ;;
  build)
    udid="${udid:-$(worktree_udid)}"
    xcodebuild_app build
    ;;
  test)
    udid="${udid:-$(worktree_udid)}"
    boot
    xcodebuild_app test
    ;;
  run)
    udid="${udid:-$(worktree_udid)}"
    xcodebuild_app build
    boot
    open "devices:///manage/select?id=$udid"  # Xcode 27 shows simulators through this URL, like local-review
    xcrun simctl install "$udid" "$derived_data/Build/Products/Debug-iphonesimulator/Later.app"
    xcrun simctl launch "$udid" "$bundle_id"
    ;;
  *)
    echo "error: unknown action: $action" >&2
    exit 2
    ;;
esac
