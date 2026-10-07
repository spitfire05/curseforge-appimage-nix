# AGENTS.md

## Development commands
- `nix build` — build package (CI command; run after hash edits)
- `nix fmt` — format with alejandra (flake formatter); `nix fmt -- --check` for verification
- `nix flake check` — eval outputs (emits warnings for custom "appimage" and "homeManagerModules" attrs)
- `nix develop` — shell with alejandra; or `direnv allow` (`.envrc` = `use flake`)

## AppImage pinning & updates (key gotcha)
- `flake.nix:13` URL is versionless; `sha256` at `flake.nix:14` pins the exact binary via `fetchurl`.
- `.github/workflows/update-appimage-hash.yml` runs daily (and on dispatch) to prefetch, patch hash via sed, `nix build`, and open PR.
- `version` (`flake.nix:12`) cannot be auto-detected; bump manually on upstream release.
- PRs from update workflow use GITHUB_TOKEN → do not trigger `build.yml`; always `nix build` locally before merge if branch protection applies.
- To manually update: replicate prefetch/compare/patch steps from the workflow (uses `nix eval --raw .#appimage.*`, `nix store prefetch-file`, `nix hash convert`).

## Repository structure & boundaries
- `flake.nix` owns metadata (`appimage` attr), outputs, system list (x86_64-linux only), overlays, modules, formatter, devShells.
- `nix/package.nix` — fetchurl + stdenv mkDerivation (dontUnpack/dontBuild, makeWrapper for appimage-run + makeDesktopItem).
- `nix/module.nix` — shared; sets `environment.systemPackages` or `home.packages` under `programs.curseforge.enable`.
- No tests, no other packages, no codegen, no language-specific tooling.

## Conventions
- Format Nix with alejandra (not nixpkgs-fmt or others).
- Keep hash edit in `flake.nix` exact (update script greps for single occurrence).
- `result` and `.direnv` are build artifacts (see `.gitignore`).
- Modules are intentionally non-configurable beyond enable (package + desktop fixed).
