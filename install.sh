#!/bin/sh
set -eu

# Install the picon command.
#
#   curl -fsSL https://raw.githubusercontent.com/rafdls/pi-container/main/install.sh | sh
#
# Environment:
#   PICON_BIN_DIR  Where to install picon. Default: $HOME/.local/bin
#   PICON_REF      Branch or tag to install from. Default: main

REPO="rafdls/pi-container"
REF="${PICON_REF:-main}"
BIN_DIR="${PICON_BIN_DIR:-$HOME/.local/bin}"
SOURCE_URL="https://raw.githubusercontent.com/$REPO/$REF/bin/picon"
TARGET="$BIN_DIR/picon"

die() {
  echo "Error: $1" >&2
  exit 1
}

command -v docker >/dev/null 2>&1 \
  || die "docker is not installed. Install Docker Desktop (https://www.docker.com/products/docker-desktop/) or OrbStack (https://orbstack.dev), then run this installer again."

command -v curl >/dev/null 2>&1 || die "curl is required to download picon."

mkdir -p "$BIN_DIR"

echo "Downloading picon from $REF ..."
curl -fsSL "$SOURCE_URL" -o "$TARGET.tmp" \
  || die "could not download $SOURCE_URL. Check the ref name and your network."
chmod +x "$TARGET.tmp"
mv "$TARGET.tmp" "$TARGET"

echo "Installed $TARGET"

# Warn rather than edit the user's shell configuration, which varies by shell.
case ":$PATH:" in
  *":$BIN_DIR:"*)
    echo ""
    echo "Run it with:"
    echo "  picon ~/dev/your-project"
    ;;
  *)
    echo ""
    echo "$BIN_DIR is not on your PATH. Add it by running:"
    echo ""
    echo "  echo 'export PATH=\"$BIN_DIR:\$PATH\"' >> ~/.zshrc"
    echo ""
    echo "Then restart your shell and run:"
    echo "  picon ~/dev/your-project"
    ;;
esac

echo ""
echo "The container image downloads on your first run."
