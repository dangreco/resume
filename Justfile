root := `git rev-parse --show-toplevel`
bld  := ".build"

[private]
_default:
    @just --list

[group('Typst')]
@clean:
    #!/usr/bin/env bash
    set -euo pipefail
    rm -rf "{{root}}/{{bld}}"

[group('Typst')]
@build:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "{{root}}/{{bld}}"
    typst compile -f pdf --root "{{root}}" "{{root}}/src/main.typ" "{{root}}/{{bld}}/resume.pdf"

[group('Typst')]
@watch:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "{{root}}/{{bld}}"
    typst watch -f pdf --root "{{root}}" "{{root}}/src/main.typ" "{{root}}/{{bld}}/resume.pdf"

[group('Typst')]
@develop:
    #!/usr/bin/env bash
    set -euo pipefail
    xdg-open "{{root}}/{{bld}}/resume.pdf"
    mkdir -p "{{root}}/{{bld}}"
    typst watch -f pdf --root "{{root}}" "{{root}}/src/main.typ" "{{root}}/{{bld}}/resume.pdf"

[group('Release')]
sign:
    #!/usr/bin/env bash
    set -euo pipefail

    [ -f "{{root}}/.env" ] && source "{{root}}/.env" 2>/dev/null || true

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

    just clean
    just build

    (cd "{{root}}/{{bld}}" && sha256sum resume.pdf) > "{{root}}/{{bld}}/checksums.txt"
    gpg --batch --yes --passphrase "$GPG_PASSPHRASE" --output "{{root}}/{{bld}}/resume.pdf.asc" --armor --detach-sign "{{root}}/{{bld}}/resume.pdf"
