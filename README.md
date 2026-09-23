# curseforge-appimage-nix

Run a third-party AppImage on NixOS via [`appimage-run`](https://search.nixos.org/packages?channel=unstable&show=appimage-run), with an optional xdg desktop entry.

The package, AppImage URL/hash and desktop entry are hardcoded in `flake.nix`; nothing is configurable per-consumer.

## Usage

### Direct package

```nix
# nix build .#  or  nix run .
nix run github:spitfire05/curseforge-appimage-nix
```

### Overlay

```nix
{
  inputs.curseforge.url = "github:spitfire05/curseforge-appimage-nix";

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
