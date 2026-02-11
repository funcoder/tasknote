#!/bin/bash
set -euo pipefail

PRODUCT="TaskNote"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$PRODUCT.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo "Building $PRODUCT..."
swift build -c release 2>&1

EXECUTABLE=$(swift build -c release --show-bin-path)/$PRODUCT

echo "Assembling $PRODUCT.app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS" "$RESOURCES"

cp "$EXECUTABLE" "$MACOS/$PRODUCT"
cp Resources/Info.plist "$CONTENTS/Info.plist"

echo "Code signing (ad-hoc)..."
codesign --force --sign - "$APP_BUNDLE"

echo "Build complete: $APP_BUNDLE"

if [[ "${1:-}" == "--zip" ]]; then
    echo "Creating distributable zip..."
    cd "$BUILD_DIR"
    zip -r "$PRODUCT.zip" "$PRODUCT.app"
    cd ..
    echo "Created: $BUILD_DIR/$PRODUCT.zip"
    echo "Note: Recipients may need to run: xattr -cr $PRODUCT.app"
fi
