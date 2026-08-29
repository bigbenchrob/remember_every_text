#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────
# build_and_notarize.sh — Build, sign, package, and notarize MessageLens
# ──────────────────────────────────────────────────────────────────────
#
# Default distribution path:
#   Use this script for any build that will be shared outside the local
#   machine. A plain `flutter build macos --release` is only a local release
#   build; it is not the repo's default distribution artifact. The default
#   output is a notarized `MessageLens-latest.dmg` written to the Desktop.
#
# Prerequisites (one-time setup):
#   1. Developer ID Application certificate in Keychain
#   2. App-specific password from https://appleid.apple.com
#   3. Store credentials:
#        xcrun notarytool store-credentials "notarytool-password" \
#          --apple-id "bigbenchrob@gmail.com" \
#          --team-id "FQHT2QP3NE" \
#          --password "YOUR_APP_SPECIFIC_PASSWORD"
#
# Usage:
#   ./tool/build_and_notarize.sh               # Default distribution pipeline -> ~/Desktop/MessageLens-latest.dmg
#   ./tool/build_and_notarize.sh --skip-build  # Repackage existing release build
#   ./tool/build_and_notarize.sh --candidate-only
#                                               # Build, sign, and verify without publishing
#   ./tool/build_and_notarize.sh --artifact-only
#                                               # Build, sign, notarize, and stop before publishing
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_ROOT="${APP_ROOT:-$PROJECT_DIR}"
APP_NAME="MessageLens"
APP_PATH="$PROJECT_DIR/build/macos/Build/Products/Release/$APP_NAME.app"
CANDIDATE_ROOT="$PROJECT_DIR/build/production-candidate"
CANDIDATE_APP_PATH="$CANDIDATE_ROOT/$APP_NAME.app"
ARCHIVE_IDENTITY_VERIFIER="$PROJECT_DIR/tool/verify_macos_archive_identity.sh"
DMG_PATH="$HOME/Desktop/$APP_NAME-latest.dmg"
KEYCHAIN_PROFILE="notarytool-password"
SIGNING_IDENTITY="Developer ID Application: Robert Campbell (FQHT2QP3NE)"
EXTRACTOR_PATH="$APP_PATH/Contents/MacOS/extract_messages_limited"
PUBSPEC_FILE="$APP_ROOT/pubspec.yaml"
TESTER_PORTAL_ROOT="${TESTER_PORTAL_ROOT:-$HOME/Development/website/MessageLens}"
TESTER_PORTAL_DOWNLOADS_DIR="${TESTER_PORTAL_DOWNLOADS_DIR:-$TESTER_PORTAL_ROOT/assets/downloads}"
TESTER_PORTAL_DATA_DIR="${TESTER_PORTAL_DATA_DIR:-$TESTER_PORTAL_ROOT/assets/data}"
LATEST_BUILD_METADATA_FILE="${LATEST_BUILD_METADATA_FILE:-$TESTER_PORTAL_DATA_DIR/latest-build.json}"
TESTER_PORTAL_PACKAGE_FILE="${TESTER_PORTAL_PACKAGE_FILE:-$TESTER_PORTAL_ROOT/package.json}"
PORTAL_BUILD_STATUS="${PORTAL_BUILD_STATUS:-Beta}"
PORTAL_BUILD_PLATFORM="${PORTAL_BUILD_PLATFORM:-macOS}"
PORTAL_BUILD_CHANNEL="${PORTAL_BUILD_CHANNEL:-Production tester build}"
PORTAL_REQUIRES_DATA_RESET="${PORTAL_REQUIRES_DATA_RESET:-false}"
SKIP_BUILD=false
CANDIDATE_ONLY=false
ARTIFACT_ONLY=false

# ── Helpers ───────────────────────────────────────────────────────────

step() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  $1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

fail() {
  echo "❌ $1" >&2
  exit 1
}

for argument in "$@"; do
  case "$argument" in
    --skip-build)
      SKIP_BUILD=true
      ;;
    --candidate-only)
      CANDIDATE_ONLY=true
      ;;
    --artifact-only)
      ARTIFACT_ONLY=true
      ;;
    --help|-h)
      sed -n '1,32p' "$0"
      exit 0
      ;;
    *)
      fail "Unknown argument: $argument"
      ;;
  esac
done

if [[ "$CANDIDATE_ONLY" == "true" && "$ARTIFACT_ONLY" == "true" ]]; then
  fail "--candidate-only and --artifact-only cannot be used together"
fi

extract_app_version() {
  local version_line
  version_line="$(awk '/^version: / {print $2; exit}' "$PUBSPEC_FILE")"
  [[ -n "$version_line" ]] || fail "Could not read app version from $PUBSPEC_FILE"
  echo "$version_line"
}

write_latest_build_metadata() {
  local version="$1"
  local build_date_iso="$2"
  local build_date_display="$3"
  local download_file="$4"
  local metadata_tmp

  metadata_tmp="${LATEST_BUILD_METADATA_FILE}.tmp"
  cat > "$metadata_tmp" <<EOF
{
  "version": "$version",
  "buildDate": "$build_date_iso",
  "buildDateDisplay": "$build_date_display",
  "status": "$PORTAL_BUILD_STATUS",
  "platform": "$PORTAL_BUILD_PLATFORM",
  "channel": "$PORTAL_BUILD_CHANNEL",
  "downloadFile": "$download_file",
  "downloadPath": "./assets/downloads/$download_file",
  "requiresDataReset": $PORTAL_REQUIRES_DATA_RESET,
  "requiresDataResetDisplay": "$( [[ "$PORTAL_REQUIRES_DATA_RESET" == "true" ]] && echo "Required" || echo "Not required" )"
}
EOF
  mv "$metadata_tmp" "$LATEST_BUILD_METADATA_FILE"
}

# ── Step 1: Build ─────────────────────────────────────────────────────

if [[ "$SKIP_BUILD" != "true" ]]; then
  step "Step 1/9: Building release"
  cd "$PROJECT_DIR"
  flutter build macos --release
else
  step "Step 1/9: Skipping build (--skip-build)"
fi

[[ -d "$APP_PATH" ]] || fail "App not found at $APP_PATH"
[[ -x "$ARCHIVE_IDENTITY_VERIFIER" ]] \
  || fail "Archive identity verifier is missing or not executable"

step "Verifying production archive identity metadata"
"$ARCHIVE_IDENTITY_VERIFIER" \
  --app "$APP_PATH" \
  --environment production \
  --metadata-only

# ── Step 2: Re-sign embedded frameworks and the app ──────────────────

step "Step 2/9: Re-signing embedded frameworks and app bundle"

# Re-sign every embedded framework with the Developer ID identity
# and hardened runtime.  This fixes stale signatures left by build tools.
FRAMEWORKS_DIR="$APP_PATH/Contents/Frameworks"
if [[ -d "$FRAMEWORKS_DIR" ]]; then
  for fw in "$FRAMEWORKS_DIR"/*.framework "$FRAMEWORKS_DIR"/*.dylib; do
    [[ -e "$fw" ]] || continue
    echo "  Signing: $(basename "$fw")"
    codesign --force --sign "$SIGNING_IDENTITY" \
      --options runtime \
      --timestamp \
      "$fw"
  done
fi

if [[ -f "$EXTRACTOR_PATH" ]]; then
  echo "  Signing: $(basename "$EXTRACTOR_PATH")"
  codesign --force --sign "$SIGNING_IDENTITY" \
    --options runtime \
    --timestamp \
    "$EXTRACTOR_PATH"
fi

# Re-sign the main app bundle (picks up the freshly signed frameworks)
echo "  Signing: $APP_NAME.app"
codesign --force --sign "$SIGNING_IDENTITY" \
  --options runtime \
  --entitlements "$PROJECT_DIR/macos/Runner/Release.entitlements" \
  --timestamp \
  "$APP_PATH"

# ── Step 3: Verify code signature ────────────────────────────────────

step "Step 3/9: Verifying code signature"
"$ARCHIVE_IDENTITY_VERIFIER" \
  --app "$APP_PATH" \
  --environment production
echo "Signing identity:"
codesign -dvv "$APP_PATH" 2>&1 | grep "Authority=" | head -1

if [[ "$CANDIDATE_ONLY" == "true" ]]; then
  step "Preparing non-publishing production candidate"
  rm -rf "$CANDIDATE_APP_PATH"
  mkdir -p "$CANDIDATE_ROOT"
  ditto "$APP_PATH" "$CANDIDATE_APP_PATH"
  "$ARCHIVE_IDENTITY_VERIFIER" \
    --app "$CANDIDATE_APP_PATH" \
    --environment production
  echo ""
  echo "✅ Signed production candidate ready at: $CANDIDATE_APP_PATH"
  echo "✅ No DMG, notarization submission, tester-portal build, or publication was performed."
  echo "✅ The candidate was not installed or launched."
  exit 0
fi

# ── Step 4: Create DMG ───────────────────────────────────────────────

step "Step 4/9: Creating DMG"
rm -f "$DMG_PATH"
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$APP_PATH" \
  -ov \
  -format UDZO \
  "$DMG_PATH"
echo "DMG created: $DMG_PATH"

# ── Step 5: Submit for notarization ──────────────────────────────────

step "Step 5/9: Submitting for notarization (this may take a few minutes)"
xcrun notarytool submit "$DMG_PATH" \
  --keychain-profile "$KEYCHAIN_PROFILE" \
  --wait

# ── Step 6: Staple the ticket ────────────────────────────────────────

step "Step 6/9: Stapling notarization ticket to DMG"
xcrun stapler staple "$DMG_PATH"

# ── Step 7: Final verification ───────────────────────────────────────

step "Step 7/9: Verifying notarization"
# spctl --assess on DMGs can give false "rejected" results.
# Instead, verify the staple is present and the app itself passes.
xcrun stapler validate "$DMG_PATH" 2>&1
echo "Notarization ticket is stapled to DMG."
echo ""
echo "Verifying app bundle signature:"
spctl --assess --verbose=2 "$APP_PATH" 2>&1 || true

if [[ "$ARTIFACT_ONLY" == "true" ]]; then
  echo ""
  echo "✅ Signed and notarized production artifact ready at: $DMG_PATH"
  echo "✅ No tester-portal build, metadata update, publication, installation, or launch was performed."
  exit 0
fi

# ── Step 8: Build tester portal pages ────────────────────────────────

step "Step 8/9: Building tester portal pages"

[[ -f "$PUBSPEC_FILE" ]] || fail "pubspec.yaml not found at $PUBSPEC_FILE"
[[ -d "$TESTER_PORTAL_ROOT" ]] || fail "Tester portal root not found at $TESTER_PORTAL_ROOT"
[[ -f "$DMG_PATH" ]] || fail "Finalized DMG not found at $DMG_PATH"
[[ -f "$TESTER_PORTAL_PACKAGE_FILE" ]] || fail "Tester portal package.json not found at $TESTER_PORTAL_PACKAGE_FILE"
command -v npm >/dev/null 2>&1 || fail "npm is required to build tester portal pages"

(
  cd "$TESTER_PORTAL_ROOT"
  npm run build
)

# ── Step 9: Publish tester portal metadata ───────────────────────────

step "Step 9/9: Publishing tester portal release metadata"

mkdir -p "$TESTER_PORTAL_DOWNLOADS_DIR"
mkdir -p "$TESTER_PORTAL_DATA_DIR"

APP_VERSION="$(extract_app_version)"
BUILD_DATE_ISO="$(date -u +%F)"
BUILD_DATE_DISPLAY="$(LC_ALL=C date '+%B %e, %Y at %l:%M %p %Z' | tr -s ' ')"
DOWNLOAD_FILE="$(basename "$DMG_PATH")"

cp "$DMG_PATH" "$TESTER_PORTAL_DOWNLOADS_DIR/$DOWNLOAD_FILE"
write_latest_build_metadata \
  "$APP_VERSION" \
  "$BUILD_DATE_ISO" \
  "$BUILD_DATE_DISPLAY" \
  "$DOWNLOAD_FILE"

echo ""
echo "✅ Done! Notarized DMG ready at: $DMG_PATH"
echo "✅ Tester portal artifact copied to: $TESTER_PORTAL_DOWNLOADS_DIR/$DOWNLOAD_FILE"
echo "✅ Tester portal metadata updated at: $LATEST_BUILD_METADATA_FILE"
echo ""
