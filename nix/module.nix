# Module shared between NixOS (`target = "nixos"`) and Home Manager
# (`target = "home-manager"`). The package, AppImage and desktop entry are
# fixed in flake.nix and are not configurable.
{
  appimage,
  target,
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  package = import ./package.nix {inherit pkgs appimage;};

  packagesTarget =
    if target == "nixos"
    then "environment.systemPackages"
    else if target == "home-manager"
    then "home.packages"
    else throw "lib/module.nix: unknown target '${target}'";
in {
  options.programs.curseforge = {
    enable = lib.mkEnableOption "CurseForge AppImage package";
  };

  config = lib.mkIf config.programs.curseforge.enable (
    lib.setAttrByPath (lib.splitString "." packagesTarget) [package]
  );
}
