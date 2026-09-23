{
  description = "Run a third-party AppImage on NixOS via appimage-run";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    appimage = {
      pname = "curseforge";
      version = "1.321.1-39714";
      url = "https://curseforge.overwolf.com/downloads/curseforge-latest-linux.AppImage";
      sha256 = "0iyi8rz4k8dcml802g43a3v4h65y7sz0gahc31h8s6f9b8v1jd70";
      desktopEntry = {
        name = "CurseForge";
        comment = "CurseForge desktop app";
        icon = null;
        categories = [
          "Network"
          "FileTransfer"
        ];
      };
    };

    mkPackage = pkgs: appimage:
      import ./nix/package.nix {inherit pkgs appimage;};
    mkModule = target: import ./nix/module.nix {inherit appimage target;};

    eachSystem = nixpkgs.lib.genAttrs [
      "x86_64-linux"
    ];

    pkgsFor = system: nixpkgs.legacyPackages.${system};
  in {
    formatter = eachSystem (system: nixpkgs.legacyPackages.${system}.alejandra);

    packages = eachSystem (system: {
      default = mkPackage nixpkgs.legacyPackages.${system} appimage;
    });

    overlays.default = final: _prev: {
      ${appimage.pname} = mkPackage final appimage;
    };

    nixosModules.default = mkModule "nixos";
    homeManagerModules.default = mkModule "home-manager";

    devShells = eachSystem (system: {
      default = (pkgsFor system).mkShellNoCC {
        packages = with pkgsFor system; [
          alejandra
        ];
      };
    });
  };
}
