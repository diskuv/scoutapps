#!/bin/sh
# SOURCE: The authoritative source of this script is dksdk-coder/packaging/codesign-macos.sh
# Arguments:
#   projectdir
#   bundle - May be a .app, .bundle or .dmg per https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution
#   arch - arm64 or x86_64
set -eufx

projectdir=$1
shift
bundle=$1
shift
arch=$1
shift

case "$arch" in
arm64|x86_64) ;;
*) echo "FATAL: arch must be arm64 or x86_64, not '$arch'"; exit 1
esac

# Stapling requires an .app or .dmg but not .bundle for some reason, even though it works on bundles (confirmed with DkCoder).
origext="${bundle##*.}"
case "$origext" in
dmg) staple_ext=.dmg ;;
bundle) staple_ext=.app ;;
app) staple_ext=.app ;;
*) echo "FATAL: bundle extension must be .dmg, .app or .bundle"; exit 1
esac

cd "$projectdir"

HOMEBREW_NO_AUTO_UPDATE=1 /opt/homebrew/bin/brew install jq
/usr/bin/install -d "sign/darwin_${arch}" sign-audit

# notarize (scan for malware)
/bin/rm -f "sign/SonicScoutQRScanner.signed_pre_notary.${arch}.zip"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "${bundle}" "sign/SonicScoutQRScanner.signed_pre_notary.${arch}.zip"
/usr/bin/xcrun notarytool submit "sign/SonicScoutQRScanner.signed_pre_notary.${arch}.zip" \
    --keychain-profile "notarytool-password" --wait \
    --output-format json | /usr/bin/tee "sign/notary-${arch}.json"

# always save logs (these are safe and valuable for public storage in git repository)
notarizationid=$(/opt/homebrew/bin/jq -r .id "sign/notary-${arch}.json")
/usr/bin/xcrun notarytool log --keychain-profile "notarytool-password" "$notarizationid" "sign-audit/$notarizationid.json"

# stapling so end-user notarization check can be performed offline
/bin/mv "${bundle}" "sign/darwin_${arch}/SonicScoutQRScanner${staple_ext}"
/usr/bin/xcrun stapler staple "sign/darwin_${arch}/SonicScoutQRScanner${staple_ext}"
/bin/mv "sign/darwin_${arch}/SonicScoutQRScanner${staple_ext}" "${bundle}"
