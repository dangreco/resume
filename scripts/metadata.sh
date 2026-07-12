#!/usr/bin/env bash
set -euo pipefail

# Generates _build/release.json, describing the release and its artifacts.
# Expects the build (and, in CI, the signing) to have already run.

BUILD_DIR="_build"
PDF="$BUILD_DIR/resume.en.pdf"
OUT="$BUILD_DIR/release.json"

if [[ ! -f "$PDF" ]]; then
    echo "$PDF not found; run 'task typst:build' first"
    exit 1
fi

# VERSION only exists once a release has been cut, so local runs and any CD run
# before the first release fall back to a placeholder.
version="0.0.0-dev"
[[ -f VERSION ]] && version="$(cat VERSION)"

commit="$(git rev-parse HEAD)"
released_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

info="$(pdfinfo "$PDF")"
pages="$(awk '/^Pages:/ { print $2 }' <<<"$info")"
title="$(sed -n 's/^Title:[[:space:]]*//p' <<<"$info")"

content_type() {
    case "$1" in
    *.pdf) echo "application/pdf" ;;
    *.asc) echo "application/pgp-signature" ;;
    *.txt) echo "text/plain" ;;
    *.json) echo "application/json" ;;
    *) echo "application/octet-stream" ;;
    esac
}

# Describe every build artifact except the metadata file itself.
artifacts="$(
    for path in "$BUILD_DIR"/*; do
        name="$(basename "$path")"
        [[ "$name" == "$(basename "$OUT")" ]] && continue

        # wc -c rather than stat, whose flags differ between GNU and BSD.
        args=(
            --arg name "$name"
            --argjson size_bytes "$(wc -c <"$path")"
            --arg sha256 "$(sha256sum "$path" | cut -d' ' -f1)"
            --arg content_type "$(content_type "$name")"
        )
        filter='{ name: $name, size_bytes: $size_bytes, sha256: $sha256, content_type: $content_type }'

        if [[ -f "$BUILD_DIR/$name.asc" ]]; then
            args+=(--arg signature "$name.asc")
            filter+=' + { signature: $signature }'
        fi

        jq -n "${args[@]}" "$filter"
    done | jq -s '.'
)"

jq -n \
    --arg version "$version" \
    --arg released_at "$released_at" \
    --arg commit "$commit" \
    --argjson pages "$pages" \
    --arg title "$title" \
    --argjson artifacts "$artifacts" \
    '{
        version: $version,
        released_at: $released_at,
        commit: $commit,
        document: { pages: $pages, title: $title },
        artifacts: $artifacts,
    }' >"$OUT"

echo "Wrote $OUT"
