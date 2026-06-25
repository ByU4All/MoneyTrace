#!/usr/bin/env bash
# MoneyTrace — Release build script
# Produces a signed AAB + APK with debug symbols ready for Play Console upload.
#
# Usage:
#   chmod +x build_release.sh   (first time only)
#   ./build_release.sh
#
# Output:
#   build/release/moneytrace-<version>.aab          → upload to Play Console
#   build/release/moneytrace-<version>.apk          → sideload / direct install
#   build/release/debug-symbols-<version>.zip       → upload to Play Console
#                                                      (Vitals → Deobfuscation files)

set -euo pipefail

# ---------------------------------------------------------------------------
# 1. Read version from pubspec.yaml
# ---------------------------------------------------------------------------
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
echo "Building MoneyTrace v$VERSION"

# ---------------------------------------------------------------------------
# 2. Clean previous outputs
# ---------------------------------------------------------------------------
OUTDIR="build/release"
SYMBOLS_DIR="$OUTDIR/debug-symbols"
mkdir -p "$OUTDIR"
rm -rf "$SYMBOLS_DIR"
mkdir -p "$SYMBOLS_DIR"

# ---------------------------------------------------------------------------
# 3. Build AAB (Play Store)
# ---------------------------------------------------------------------------
echo ""
echo "→ Building AAB..."
flutter build appbundle --release \
  --split-debug-info="$SYMBOLS_DIR" \
  --obfuscate

cp build/app/outputs/bundle/release/app-release.aab \
   "$OUTDIR/moneytrace-${VERSION}.aab"

# ---------------------------------------------------------------------------
# 4. Build APK (sideload / direct install)
# ---------------------------------------------------------------------------
echo ""
echo "→ Building APK..."
flutter build apk --release \
  --split-debug-info="$SYMBOLS_DIR" \
  --obfuscate

cp build/app/outputs/flutter-apk/app-release.apk \
   "$OUTDIR/moneytrace-${VERSION}.apk"

# ---------------------------------------------------------------------------
# 5. Zip debug symbols
# ---------------------------------------------------------------------------
echo ""
echo "→ Packaging debug symbols..."
SYMBOLS_ZIP="$OUTDIR/debug-symbols-${VERSION}.zip"
(cd "$SYMBOLS_DIR" && zip -r "../debug-symbols-${VERSION}.zip" .)
echo "   Symbols: $SYMBOLS_ZIP"

# ---------------------------------------------------------------------------
# 6. Summary
# ---------------------------------------------------------------------------
echo ""
echo "✓ Done — files in $OUTDIR/:"
ls -lh "$OUTDIR/"*.aab "$OUTDIR/"*.apk "$OUTDIR/"*.zip 2>/dev/null
echo ""
echo "Next steps:"
echo "  1. Upload  moneytrace-${VERSION}.aab         → Play Console → Production"
echo "  2. Upload  debug-symbols-${VERSION}.zip      → Play Console → App bundle → ⋮ → Upload deobfuscation file"
