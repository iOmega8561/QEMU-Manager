#!/bin/bash
# Absolute path to this script.
SCRIPT=$(readlink -f $0)
# Absolute path this script is in.
SCRIPTPATH=`dirname $SCRIPT`

# Exit on error
set -e

# Check if an archive path is provided
if [ "$#" -ne 1 ]; then
    echo "❌ Error: No archive path provided."
    echo "Usage: $0 <path-to-archive>"
    exit 1
fi

ARCHIVE_PATH="$1"

# Check if the given archive exists
if [ ! -d "$ARCHIVE_PATH" ]; then
    echo "❌ Error: The archive path '$ARCHIVE_PATH' does not exist."
    exit 1
fi

# Fetching environment variables
source "${SCRIPTPATH}/.env"

if [[ -z "${APP_NAME}" || \
      -z "${APPLE_ID}" || \
      -z "${TEAM_ID}"  || \
      -z "${DEV_NAME}" || \
      -z "${KEYCHAIN_PROFILE}" ]]; then
    echo "❌ Error: Some environment variables are not set."
    exit 1
fi

# To store credentials in the system keychain
# This should be already done before running the script
# xcrun notarytool store-credentials "notarytool-profile" \
#     --apple-id "${APPLE_ID}" \
#     --team-id "${TEAM_ID}" \
#     --password "${APP_PASSWORD}"

CERTIFICATE_NAME="Developer ID Application: ${DEV_NAME} (${TEAM_ID})"

# Cleanup old builds
rm -rf "${APP_NAME}.app" \
    "${APP_NAME}.dmg" \
    DMG

echo "🛠 ️ Copying Release from archive..."
cp -R "${ARCHIVE_PATH}/Products/Applications/${APP_NAME}.app" "./${APP_NAME}.app"

echo "🔑 Signing Release..."
ENTITLEMENTS_FILE=$(find "${SCRIPTPATH}" -type f | grep .entitlements)
find "${APP_NAME}.app" -type f -perm +111 -exec sh -c '
   xattr -c "$1" && 
   codesign --force --strict --options runtime --timestamp \
       --entitlements "'"${ENTITLEMENTS_FILE}"'" --sign "'"$CERTIFICATE_NAME"'" "$1"
' sh {} \;

codesign --force \
    --deep \
    --strict \
    --options runtime \
    --timestamp \
    --sign "$CERTIFICATE_NAME" \
    "${APP_NAME}.app"

echo "📦 Packaging Application Package..."
mkdir -p DMG
cp -R "${APP_NAME}.app" DMG/
cp "${SCRIPTPATH}/LICENSE" DMG/

hdiutil create -volname "${APP_NAME}" \
  -srcfolder ./DMG \
  -format UDZO \
  -ov "./${APP_NAME}.dmg"

echo "🔑 Signing DMG Package..."
codesign \
    --force \
    --sign "$CERTIFICATE_NAME" \
    "${APP_NAME}.dmg"

echo "📤 Submitting for Notarization..."
xcrun notarytool submit "${APP_NAME}.dmg" \
    --keychain-profile "$KEYCHAIN_PROFILE" \
    --wait

echo "📎 Stapling Notarization..."
xcrun stapler staple "${APP_NAME}.dmg"

rm -fr DMG
rm -fr "${APP_NAME}.app"

echo "✅ Done! ${APP_NAME}.dmg is notarized and ready for distribution."
