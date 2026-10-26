#!/usr/bin/env bash
set -e

# TryOn - One-Click Build & Run Script
# Usage:
#   ./run.sh          # Auto-detects connected device (Android or iOS) and runs
#   ./run.sh android  # Runs on Android device/emulator
#   ./run.sh ios      # Runs on iPhone / iOS simulator
#   ./run.sh web      # Runs on Chrome browser
#   ./run.sh test     # Executes the automated unit test suite

TARGET="${1:-auto}"

echo "========================================="
echo "   TryOn - Virtual Try-On & 3D 360 Studio"
echo "========================================="

# 1. Search for Flutter in common directories if not currently in PATH
if ! command -v flutter &> /dev/null; then
    COMMON_FLUTTER_PATHS=(
        "$HOME/development/flutter/bin"
        "$HOME/flutter/bin"
        "/snap/bin"
        "/opt/flutter/bin"
        "/usr/local/flutter/bin"
    )
    for p in "${COMMON_FLUTTER_PATHS[@]}"; do
        if [ -x "$p/flutter" ]; then
            echo "[+] Located Flutter at: $p"
            export PATH="$p:$PATH"
            break
        fi
    done
fi

# Re-check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "[!] Flutter SDK was not found in PATH or standard install directories."
    echo ""
    echo "    To install Flutter on your machine:"
    echo "    --------------------------------------------------"
    echo "    Option A (Ubuntu / Snap):"
    echo "      sudo snap install flutter --classic"
    echo ""
    echo "    Option B (Git Clone to ~/development/flutter):"
    echo "      mkdir -p ~/development && cd ~/development"
    echo "      git clone https://github.com/flutter/flutter.git -b stable"
    echo "      echo 'export PATH=\"\$HOME/development/flutter/bin:\$PATH\"' >> ~/.bashrc"
    echo "      source ~/.bashrc"
    echo "    --------------------------------------------------"
    echo ""
    echo "    Once Flutter is installed, rerun: ./run.sh"
    exit 1
fi

echo "[+] Flutter detected: $(flutter --version | head -n 1)"

# 2. Get dependencies
echo "[+] Fetching dependencies (flutter pub get)..."
flutter pub get

# 3. Handle target action
case "$TARGET" in
    test)
        echo "[+] Running unit tests..."
        flutter test
        ;;
    android)
        echo "[+] Launching on Android..."
        flutter run -d android
        ;;
    ios)
        echo "[+] Launching on iPhone / iOS Simulator..."
        cd ios && pod install && cd ..
        flutter run -d ios
        ;;
    web)
        echo "[+] Launching on Chrome..."
        flutter run -d chrome
        ;;
    auto)
        echo "[+] Launching on available device..."
        flutter run
        ;;
    *)
        echo "[!] Unknown target: $TARGET"
        echo "    Supported options: android, ios, web, test"
        exit 1
        ;;
esac
