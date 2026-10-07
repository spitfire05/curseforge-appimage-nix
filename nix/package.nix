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

  icons =
    pkgs.runCommand "${pname}-icons" {
      nativeBuildInputs = with pkgs; [binutils squashfsTools];
      src = appimageFile;
      inherit pname;
    } ''
      offset=$(LC_ALL=C readelf -h "$src" | awk 'NR==13{e_shoff=$5} NR==18{e_shentsize=$5} NR==19{e_shnum=$5} END{print e_shoff+e_shentsize*e_shnum}')
      mkdir -p "$out/share/icons"
      unsquashfs -q -o "$offset" -d "$TMPDIR/sq" "$src" "usr/share/icons/hicolor/*/apps/$pname.png" || true
      [ -d "$TMPDIR/sq/usr/share/icons/hicolor" ] && cp -r "$TMPDIR/sq/usr/share/icons/hicolor" "$out/share/icons/"
    '';
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

        cp -r ${icons}/share/icons "$out/share" 2>/dev/null || true

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
