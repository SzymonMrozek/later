#!/usr/bin/env bash
# Builds, tests and runs the iOS app on this worktree's own simulator (pitcrew worktree-simulator).
#   scripts/ios.sh build|test|run [--udid UDID]
#   scripts/ios.sh device [--udid UDID]    Ad Hoc build on a connected iPhone registered with the team
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

bundle_id="com.later"
derived_data=".build/ios"
worktree_simulator="tools/pitcrew/worktree-simulator/worktree_simulator.py"
# The app talks to this worktree's Phoenix server (`mise run server:dev`); Project.swift bakes it into Info.plist.
export TUIST_LATER_API_BASE_URL="http://localhost:${PORT:-4000}"

# Reuses the device recorded for this worktree; the primary worktree gets one on first use.
worktree_udid() {
  python3 "$worktree_simulator" create --name "Later $(git branch --show-current | tr '/' '-')"
}

# A freshly created device can't launch apps until its first boot finishes.
boot() {
  xcrun simctl bootstatus "$udid" -b >/dev/null
}

# The first paired iPhone that devicectl can reach.
connected_iphone() {
  local devices
  devices="$(mktemp)"
  xcrun devicectl list devices --quiet --json-output "$devices"
  python3 - "$devices" <<'PY'
import json, sys

devices = json.load(open(sys.argv[1]))["result"]["devices"]
phones = [
    device["hardwareProperties"]["udid"]
    for device in devices
    if device["hardwareProperties"].get("reality") == "physical"
    and device["hardwareProperties"].get("deviceType") == "iPhone"
    and device["connectionProperties"].get("pairingState") == "paired"
]
if not phones:
    sys.exit("error: no paired iPhone found; connect one or pass --udid")
print(phones[0])
PY
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
  device)
    udid="${udid:-$(connected_iphone)}"
    crem profiles download --kind ad-hoc --app Later --environment Production --install
    # The phone reaches this worktree's server (`mise run server:lan`) by the Mac's Bonjour name.
    export TUIST_LATER_API_BASE_URL="http://$(scutil --get LocalHostName).local:${PORT:-4000}"
    (cd ios && tuist generate --no-open >/dev/null)
    xcodebuild build -quiet \
      -workspace ios/Later.xcworkspace \
      -scheme Later \
      -configuration Release \
      -destination "generic/platform=iOS" \
      -derivedDataPath "$derived_data"
    xcrun devicectl device install app --device "$udid" "$derived_data/Build/Products/Release-iphoneos/Later.app"
    xcrun devicectl device process launch --device "$udid" "$bundle_id"
    ;;
  *)
    echo "error: unknown action: $action" >&2
    exit 2
    ;;
esac
