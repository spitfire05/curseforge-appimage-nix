{
  description = "Run a third-party AppImage on NixOS via appimage-run";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    appimage = rec {
      pname = "curseforge";
      version = "1.322.0.40357-flake.1";
      url = "https://curseforge.overwolf.com/downloads/curseforge-latest-linux.AppImage";
      sha256 = "0qbawqvggnqii60zixd657qn29nbbqy7j21c6ga0ymnjv1hxfhzh";
      desktopEntry = {
        name = "CurseForge";
        comment = "CurseForge desktop app";
        icon = pname;
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
    appimage = appimage;

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
