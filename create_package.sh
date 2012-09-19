#!/bin/bash


APPNAME="DAFGU Migration Status.app"
PKGSCRIPTS=installer_scripts
PKGVERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "build/Release/$APPNAME/Contents/Info.plist")
PKGID="se.gu.it.DAFGU-Migration-Status"
PKGFILE="DAFGUMigrationStatus-$PKGVERSION.pkg"
PKGTARGET="10.5"
PKGTITLE="DAFGU Migration Status"

PACKAGEMAKER=""
if [ -e "/Developer/usr/bin/packagemaker" ]; then
    PACKAGEMAKER="/Developer/usr/bin/packagemaker"
else
    while read path; do
        if [ -e "$path/Contents/MacOS/PackageMaker" ]; then
            PACKAGEMAKER="$path/Contents/MacOS/PackageMaker"
            break
        fi
    done < <(mdfind "(kMDItemCFBundleIdentifier == com.apple.PackageMaker)")
fi
if [ -z "$PACKAGEMAKER" ]; then
    echo "packagemaker not found"
    exit 1
fi

echo "Packaging $PKGTITLE as $PKGID $PKGVERSION"

pkgroot=`mktemp -d -t dafgumigrationstatus`

echo "Creating directory structure"
mkdir -p "$pkgroot/Library/LaunchAgents"
cp "LaunchAgents/se.gu.it.DAFGU-Migration-Status.plist" "$pkgroot/Library/LaunchAgents"
mkdir -p "$pkgroot/Applications/Utilities"
ditto --noqtn "build/Release/$APPNAME" "$pkgroot/Applications/Utilities/$APPNAME"
find "$pkgroot" -name .DS_Store -print0 | xargs -0 rm -f
xattr -d -r com.apple.FinderInfo "$pkgroot"
xattr -d -r com.macromates.caret "$pkgroot"
echo "Changing owner"
sudo chown -hR root:wheel "$pkgroot"
echo "Fixing permissions"
sudo ./copymodes / "$pkgroot"
sudo "$PACKAGEMAKER" \
    --root "$pkgroot" \
    --id "$PKGID" \
    --title "$PKGTITLE" \
    --scripts "$PKGSCRIPTS" \
    --version "$PKGVERSION" \
    --target $PKGTARGET \
    --no-recommend \
    --no-relocate \
    --out "$PKGFILE"
# --info
# --resources
echo "Changing owner of $PKGFILE"
sudo chown $USER "$PKGFILE"
echo "Removing package root"
sudo rm -rf "$pkgroot"
