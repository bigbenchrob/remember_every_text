#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RELEASE_ENTITLEMENTS="$PROJECT_DIR/macos/Runner/Release.entitlements"

usage() {
  cat <<'EOF'
Usage:
  verify_macos_archive_identity.sh --app <path> --environment <production|development> [--metadata-only]

Inspects a built macOS artifact without launching it. Full production
verification also requires the approved Developer ID signature and release
entitlements.
EOF
}

fail() {
  echo "Archive identity verification failed: $1" >&2
  exit 1
}

APP_PATH=""
EXPECTED_ENVIRONMENT=""
METADATA_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app)
      APP_PATH="${2:-}"
      shift 2
      ;;
    --environment)
      EXPECTED_ENVIRONMENT="${2:-}"
      shift 2
      ;;
    --metadata-only)
      METADATA_ONLY=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "unknown argument: $1"
      ;;
  esac
done

[[ -n "$APP_PATH" ]] || fail "--app is required"
[[ -d "$APP_PATH" ]] || fail "app bundle does not exist: $APP_PATH"
[[ "$EXPECTED_ENVIRONMENT" == "production" || "$EXPECTED_ENVIRONMENT" == "development" ]] \
  || fail "--environment must be production or development"

INFO_PLIST="$APP_PATH/Contents/Info.plist"
[[ -f "$INFO_PLIST" ]] || fail "Info.plist is missing"

plist_value() {
  /usr/libexec/PlistBuddy -c "Print :$1" "$INFO_PLIST" 2>/dev/null \
    || fail "Info.plist key is missing: $1"
}

ACTUAL_ENVIRONMENT="$(plist_value MessageLensArchiveEnvironment)"
ACTUAL_BUILD_IDENTITY="$(plist_value MessageLensArchiveBuildIdentity)"
ACTUAL_BUNDLE_IDENTIFIER="$(plist_value CFBundleIdentifier)"
ACTUAL_PRODUCT_NAME="$(plist_value CFBundleDisplayName)"
ACTUAL_EXPECTED_SIGNING_IDENTITY="$(
  plist_value MessageLensExpectedSigningIdentity
)"

if [[ "$EXPECTED_ENVIRONMENT" == "production" ]]; then
  [[ "$ACTUAL_ENVIRONMENT" == "production" ]] \
    || fail "expected production environment, found $ACTUAL_ENVIRONMENT"
  [[ "$ACTUAL_BUILD_IDENTITY" == "productionRelease" ]] \
    || fail "expected productionRelease, found $ACTUAL_BUILD_IDENTITY"
  [[ "$ACTUAL_BUNDLE_IDENTIFIER" == "com.bigbenchsoftware.MessageLens" ]] \
    || fail "unexpected production bundle identifier: $ACTUAL_BUNDLE_IDENTIFIER"
  [[ "$ACTUAL_PRODUCT_NAME" == "MessageLens" ]] \
    || fail "unexpected production product name: $ACTUAL_PRODUCT_NAME"
  [[ "$ACTUAL_EXPECTED_SIGNING_IDENTITY" == \
    "Developer ID Application: Robert Campbell (FQHT2QP3NE)" ]] \
    || fail "unexpected production signing contract: $ACTUAL_EXPECTED_SIGNING_IDENTITY"
  if /usr/libexec/PlistBuddy \
    -c "Print :MessageLensDevelopmentArchiveRoot" \
    "$INFO_PLIST" >/dev/null 2>&1
  then
    fail "production metadata contains a development archive root"
  fi
else
  [[ "$ACTUAL_ENVIRONMENT" == "development" ]] \
    || fail "expected development environment, found $ACTUAL_ENVIRONMENT"
  case "$ACTUAL_BUILD_IDENTITY" in
    developmentDebug|developmentProfile|developmentRelease) ;;
    *) fail "unexpected development build identity: $ACTUAL_BUILD_IDENTITY" ;;
  esac
  [[ "$ACTUAL_BUNDLE_IDENTIFIER" == "com.bigbenchsoftware.MessageLens.development" ]] \
    || fail "unexpected development bundle identifier: $ACTUAL_BUNDLE_IDENTIFIER"
  [[ "$ACTUAL_PRODUCT_NAME" == "MessageLens Development" ]] \
    || fail "unexpected development product name: $ACTUAL_PRODUCT_NAME"
  [[ -z "$ACTUAL_EXPECTED_SIGNING_IDENTITY" ]] \
    || fail "development artifact unexpectedly requires a production signature"
fi

if [[ "$METADATA_ONLY" == "true" ]]; then
  echo "Archive identity metadata verified: $EXPECTED_ENVIRONMENT"
  if [[ "$EXPECTED_ENVIRONMENT" == "production" ]]; then
    echo "Canonical archive root contract: ~/Library/Application Support/$ACTUAL_BUNDLE_IDENTIFIER"
    echo "Full Disk Access continuity contract: stable bundle identifier and signing team FQHT2QP3NE"
  fi
  exit 0
fi

if [[ "$EXPECTED_ENVIRONMENT" == "production" ]]; then
  codesign --verify --deep --strict "$APP_PATH" >/dev/null 2>&1 \
    || fail "production code signature verification failed"
else
  # Flutter debug bundles can contain development frameworks without a complete
  # nested resource seal. Verify the app's own ad hoc signature here; the
  # production path below retains strict recursive verification.
  codesign --verify --strict "$APP_PATH" >/dev/null 2>&1 \
    || fail "development code signature verification failed"
fi

SIGNING_DETAILS="$(codesign -dvvv "$APP_PATH" 2>&1)"
if [[ "$EXPECTED_ENVIRONMENT" == "production" ]]; then
  grep -Fq "Authority=Developer ID Application: Robert Campbell (FQHT2QP3NE)" \
    <<<"$SIGNING_DETAILS" \
    || fail "approved Developer ID authority is missing"
  grep -Fq "TeamIdentifier=FQHT2QP3NE" <<<"$SIGNING_DETAILS" \
    || fail "approved signing team is missing"

  ENTITLEMENTS_FILE="$(mktemp)"
  trap 'rm -f "$ENTITLEMENTS_FILE"' EXIT
  codesign -d --entitlements "$ENTITLEMENTS_FILE" "$APP_PATH" >/dev/null 2>&1 \
    || fail "could not inspect signed entitlements"
  for key in \
    com.apple.security.app-sandbox \
    com.apple.security.cs.allow-jit \
    com.apple.security.cs.disable-library-validation \
    com.apple.security.network.client \
    com.apple.security.network.server \
    com.apple.security.personal-information.addressbook
  do
    expected="$(
      /usr/libexec/PlistBuddy -c "Print :$key" "$RELEASE_ENTITLEMENTS" 2>/dev/null
    )" \
      || fail "release entitlement contract is missing $key"
    actual="$(
      awk -v key="$key" '
        index($0, "[Key] " key) {
          getline
          getline
          sub(/^.*\[Bool\] /, "")
          print
          exit
        }
      ' "$ENTITLEMENTS_FILE"
    )"
    [[ -n "$actual" ]] || fail "signed artifact is missing entitlement $key"
    [[ "$actual" == "$expected" ]] \
      || fail "signed entitlement mismatch for $key"
  done
fi

echo "Archive identity artifact verified: $EXPECTED_ENVIRONMENT"
if [[ "$EXPECTED_ENVIRONMENT" == "production" ]]; then
  echo "Canonical archive root contract: ~/Library/Application Support/$ACTUAL_BUNDLE_IDENTIFIER"
  echo "Full Disk Access continuity contract: stable bundle identifier and signing team FQHT2QP3NE"
fi
