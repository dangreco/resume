root := `git rev-parse --show-toplevel`

_default:
    @just --list

_root:
    @echo {{ root }}

_runtimes:
    @{{ root }}/.scripts/runtimes.sh

act *args:
    @{{ root }}/.scripts/act.sh --secret-file {{root}}/.env {{ args }}

@compile:
    mkdir -p {{root}}/out && typst compile -f pdf --root {{ root }} {{root}}/src/main.typ {{root}}/out/resume.pdf

@watch:
    mkdir -p {{root}}/out && typst watch -f pdf --root {{ root }} {{root}}/src/main.typ {{root}}/out/resume.pdf

sign:
    @{{ root }}/.scripts/sign.sh
