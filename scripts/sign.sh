#!/usr/bin/env bash
set -euo pipefail

# Load environment variables from .env file if it exists
[ -f ".env" ] && source .env 2>/dev/null || true

# Check required environment variables
if [[ -z "$GPG_PRIVATE_KEY_BASE64" ]]; then
    echo "GPG_PRIVATE_KEY_BASE64 is not set"
    exit 1
fi

if [[ -z "$GPG_PASSPHRASE" ]]; then
    echo "GPG_PASSPHRASE is not set"
    exit 1
fi

# Import GPG private key
gpg=$(which gpg)

if [[ -z "$gpg" ]]; then
    echo "gpg is not installed"
    exit 1
fi

echo "$GPG_PRIVATE_KEY_BASE64" | base64 -d | gpg --batch --import &>/dev/null

# Build document
task typst:clean
task typst:build

# Sign document
(cd _build && sha256sum resume.en.pdf) > _build/checksums.txt
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" --output _build/resume.en.pdf.asc --armor --detach-sign _build/resume.en.pdf
