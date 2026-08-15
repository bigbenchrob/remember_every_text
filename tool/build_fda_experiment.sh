#!/bin/zsh

set -euo pipefail

readonly PROJECT_ROOT="${0:A:h:h}"
readonly DEVELOPMENT_ARCHIVE_ROOT="${MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT:-/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development}"
readonly SIGNING_IDENTITY="Apple Development: Rob Campbell (ZQ7EL9CA37)"
readonly DEVELOPMENT_TEAM="FQHT2QP3NE"
readonly EXPERIMENT_BUNDLE_IDENTIFIER="com.bigbenchsoftware.MessageLens.fdaexperiment"
readonly EXPERIMENT_DISPLAY_NAME="MessageLens FDA Experiment"
readonly BUILD_ROOT="$PROJECT_ROOT/build/fda_experiment"
readonly PRODUCTS_DIRECTORY="$BUILD_ROOT/Products"
readonly DERIVED_DATA_DIRECTORY="$BUILD_ROOT/DerivedData"
readonly SOURCE_APP="$PRODUCTS_DIRECTORY/MessageLens Development.app"
readonly OUTPUT_APP="$BUILD_ROOT/$EXPERIMENT_DISPLAY_NAME.app"
readonly INFO_PLIST="$OUTPUT_APP/Contents/Info.plist"
readonly LAUNCH_SERVICES_REGISTER="/System/Library/Frameworks/CoreServices.framework/Versions/Current/Frameworks/LaunchServices.framework/Versions/Current/Support/lsregister"

fail() {
  print -u2 -- "FDA experiment build failed: $1"
  exit 1
}

[[ -d "$DEVELOPMENT_ARCHIVE_ROOT" ]] || fail \
  "development archive root is unavailable: $DEVELOPMENT_ARCHIVE_ROOT"
[[ -w "$DEVELOPMENT_ARCHIVE_ROOT" ]] || fail \
  "development archive root is not writable: $DEVELOPMENT_ARCHIVE_ROOT"

security find-identity -v -p codesigning | grep -Fq "$SIGNING_IDENTITY" || fail \
  "signing identity is unavailable: $SIGNING_IDENTITY"

mkdir -p "$BUILD_ROOT"
rm -rf "$PRODUCTS_DIRECTORY" "$DERIVED_DATA_DIRECTORY" "$OUTPUT_APP"

(
  cd "$PROJECT_ROOT"
  xcodebuild \
    -workspace macos/Runner.xcworkspace \
    -scheme Runner \
    -configuration Debug \
    -derivedDataPath "$DERIVED_DATA_DIRECTORY" \
    CONFIGURATION_BUILD_DIR="$PRODUCTS_DIRECTORY" \
    build
)

[[ -d "$SOURCE_APP" ]] || fail "expected Debug product was not built: $SOURCE_APP"
ditto "$SOURCE_APP" "$OUTPUT_APP"
"$LAUNCH_SERVICES_REGISTER" -u "$SOURCE_APP" 2>/dev/null || true
rm -rf "$SOURCE_APP"

/usr/libexec/PlistBuddy -c \
  "Set :CFBundleIdentifier $EXPERIMENT_BUNDLE_IDENTIFIER" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c \
  "Set :CFBundleDisplayName $EXPERIMENT_DISPLAY_NAME" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c \
  "Set :CFBundleName $EXPERIMENT_DISPLAY_NAME" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c \
  "Set :MessageLensArchiveEnvironment development" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c \
  "Set :MessageLensArchiveBuildIdentity fdaExperiment" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Delete :LSEnvironment" "$INFO_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :LSEnvironment dict" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c \
  "Add :LSEnvironment:MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT string $DEVELOPMENT_ARCHIVE_ROOT" \
  "$INFO_PLIST"

codesign \
  --force \
  --deep \
  --generate-entitlement-der \
  --options runtime \
  --timestamp=none \
  --entitlements "$PROJECT_ROOT/macos/Runner/DebugProfile.entitlements" \
  --sign "$SIGNING_IDENTITY" \
  "$OUTPUT_APP"

codesign --verify --deep --strict --verbose=2 "$OUTPUT_APP"

[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$INFO_PLIST")" == \
  "$EXPERIMENT_BUNDLE_IDENTIFIER" ]] || fail "bundle identifier verification failed"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleDisplayName' "$INFO_PLIST")" == \
  "$EXPERIMENT_DISPLAY_NAME" ]] || fail "display-name verification failed"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :MessageLensArchiveBuildIdentity' "$INFO_PLIST")" == \
  "fdaExperiment" ]] || fail "archive build-identity verification failed"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :LSEnvironment:MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT' "$INFO_PLIST")" == \
  "$DEVELOPMENT_ARCHIVE_ROOT" ]] || fail "development-root verification failed"

print -- "Built: $OUTPUT_APP"
