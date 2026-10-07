# curseforge-appimage-nix

Nix Flake for the [CurseForge app](https://www.curseforge.com/download/app).

[![CI and smoke](https://github.com/spitfire05/curseforge-appimage-nix/actions/workflows/build.yml/badge.svg)](https://github.com/spitfire05/curseforge-appimage-nix/actions/workflows/build.yml)

## Usage

First, add this flake to your inputs:

```nix
curseforge = {
  url = "github:spitfire05/curseforge-appimage-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

### Overlay

```nix
{
  outputs = { nixpkgs, curseforge, ... }: {
    nixosConfigurations.host = nixpkgs.lib.nixosSystem {
      modules = [
        { nixpkgs.overlays = [ curseforge.overlays.default ]; }
        # now `pkgs.curseforge` is available
      ];
    };
  };
}
```

### NixOS module

Installs the package to `environment.systemPackages`, including the `.desktop` entry under `share/applications` (discovered via `$XDG_DATA_DIRS`).

```nix
{
  imports = [ curseforge.nixosModules.default ];

  programs.curseforge.enable = true;
}
```

### Home Manager module

```nix
{
  imports = [ curseforge.homeManagerModules.default ];

  programs.curseforge.enable = true;
}
```

## Options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `enable` | bool | `false` | Enable the package. |

## How it works

The AppImage is downloaded at build time with `fetchurl` (content-addressed, so its hash pins the exact binary), then wrapped so that running the generated binary invokes `nixpkgs#appimage-run` on the downloaded file. A `makeDesktopItem` entry is installed into `share/applications` so your desktop environment picks it up via the XDG spec.

Because the download URL carries no version, a new upstream release would break `fetchurl`'s hash check. The pinned `sha256` is therefore refreshed once a day by `.github/workflows/update-appimage-hash.yml`, which opens a pull request when it changes. The `version` in `flake.nix` is not machine-detectable and has to be bumped by hand.

## Footnote

Not affiliated with CurseForge in any way. Just a QoL flake.
