#!/usr/bin/env bash

root=$(just _root)
[ -f "$root/.env" ] && source "$root/.env" 2>/dev/null || true

if [[ -z "$GPG_PRIVATE_KEY_BASE64" ]]; then
    echo "GPG_PRIVATE_KEY_BASE64 is not set"
    exit 1
fi

if [[ -z "$GPG_PASSPHRASE" ]]; then
    echo "GPG_PASSPHRASE is not set"
    exit 1
fi

gpg=$(which gpg)

if [[ -z "$gpg" ]]; then
    echo "gpg is not installed"
    exit 1
fi

echo "$GPG_PRIVATE_KEY_BASE64" | base64 -d | gpg --batch --import &>/dev/null

if [[ ! -f "$root/out/resume.pdf" ]]; then
    echo "Compile resume.pdf first!"
    exit 1
fi

gpg --batch --yes --passphrase "$GPG_PASSPHRASE" --output "$root/out/resume.pdf.asc" --armor --detach-sign "$root/out/resume.pdf"
(cd "$root/out" && sha256sum resume.pdf resume.pdf.asc) > "$root/out/checksums.txt"
gpg --batch --yes --passphrase "$GPG_PASSPHRASE" --output "$root/out/checksums.txt.asc" --armor --detach-sign "$root/out/checksums.txt"
