# resume

My resume. Written in [Typst](https://typst.app), with content in `src/cfg.yml`
and layout in `src/main.typ`.

## Development

The toolchain is pinned with Nix. `direnv allow` loads it, or use
`nix develop` directly.

```sh
task build   # compile the PDF into _build/
task watch   # rebuild on change
task check   # lint and format checks
task fix     # apply formatting fixes
```

## Branching

`dev` is the integration branch and the default. Work happens on branches off
`dev` and lands there by pull request.

`main` tracks the last released state. Nothing is pushed to it directly. It is
fast-forwarded to the release commit when a release is tagged, which means a
push to `main` always signifies a release and is what triggers deployment.

## Releasing

Versions are CalVer, `YYYY.MM.N`, where `N` resets to `0` each month. The current
version lives in `VERSION` and the history in `CHANGELOG.md`; both are generated,
so neither should be edited by hand.

`release-pr` keeps a single long-lived pull request open on the `release/next`
branch, targeting `dev`. It recomputes the version and regenerates the changelog
from conventional commits on every run, so a month rollover re-targets the open
PR automatically. Merging that PR is what cuts a release.

`release-tag` fires on the resulting `VERSION` change, tags the commit,
fast-forwards `main`, and creates the GitHub Release. That release triggers
`Release` (which signs the PDF and attaches it with checksums), and the push to
`main` triggers `CD` (which deploys to S3).

The `YYYY.MM.0` release auto-merges on the 1st of each month once checks pass, so
the resume is re-signed and re-published at least monthly even when its content
has not changed. Mid-month releases are cut by merging the open release PR by
hand.

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org).
The changelog groups on the type prefix, so `content:` is used for changes to the
resume itself, alongside the usual `feat:`, `fix:`, `chore:`, and `ci:`.

### Required configuration

Releases run under a GitHub App rather than the default `GITHUB_TOKEN`, which
cannot trigger downstream workflows. The app's credentials are read from the
`RELEASE_APP_ID` and `RELEASE_APP_PRIVATE_KEY` secrets.
