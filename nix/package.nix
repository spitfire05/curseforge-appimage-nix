{
  pkgs,
  appimage,
}: let
  pname = appimage.pname;
  desktopEntry = appimage.desktopEntry;

  appimageFile = pkgs.fetchurl {
    url = appimage.url;
    sha256 = appimage.sha256;
  };

  desktopFile = pkgs.makeDesktopItem {
    name = pname;
    desktopName = desktopEntry.name;
    comment = desktopEntry.comment;
    icon = desktopEntry.icon;
    exec = pname;
    terminal = false;
    categories = desktopEntry.categories;
  };
in
  pkgs.stdenv.mkDerivation {
    pname = appimage.pname;
    version = appimage.version;

    nativeBuildInputs = [pkgs.makeWrapper];

    # The downloaded AppImage is referenced directly in the install phase,
    # so nothing needs unpacking/building here.
    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
        runHook preInstall

        install -Dm755 ${appimageFile} "$out/share/${pname}/${pname}.AppImage"

        # The AppImage is executed through `nixpkgs#appimage-run`, which
        # handles extracting/mounting the archive at runtime.
      # AppImage is executed through `nixpkgs#appimage-run`, which
      # handles extracting/mounting the archive at runtime.
      makeWrapper ${pkgs.appimage-run}/bin/appimage-run \
        "$out/bin/${pname}" \
        --add-flags "$out/share/${pname}/${pname}.AppImage"

        # XDG desktop entry (discovered via $XDG_DATA_DIRS).
        install -Dm644 ${desktopFile}/share/applications/${pname}.desktop \
          "$out/share/applications/${pname}.desktop"

        runHook postInstall
    '';
  }
