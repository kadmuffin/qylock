{ pkgs ? import <nixpkgs> {} }:

let
  patrickHand = pkgs.fetchurl {
    url = "https://github.com/google/fonts/raw/main/ofl/patrickhand/PatrickHand-Regular.ttf";
    sha256 = "1z6h9bpngs8pp2dldc4jk4gy2kmcqmbh0zxzp8jszldndhz3n5qg";
  };

  twoWeekendGoSemibold = pkgs.fetchurl {
    url = "https://gitlab.com/GuitarBro/two-weekend-go/-/raw/main/twoweekendgo-semibold.otf";
    sha256 = "0g28sy5vy8m2qnpv71g6pjhvxq2kx1x380gpri9c54diii5mpmrm";
  };

  notoSansSC = pkgs.fetchurl {
    url = "https://github.com/google/fonts/raw/main/ofl/notosanssc/NotoSansSC%5Bwght%5D.ttf";
    name = "NotoSansSC-wght.ttf";
    sha256 = "1nphka4hvvrjf8pl3gf544f9ai02bs03r58gwlfindlclw8ih153";
  };

  shojumaru = pkgs.fetchurl {
    url = "https://github.com/google/fonts/raw/main/ofl/shojumaru/Shojumaru-Regular.ttf";
    sha256 = "0x8w4ixkldbvnh63hapxxdlr2q630jw5znbj3j3699jxyh7121w6";
  };

  minecraftFont = pkgs.fetchurl {
    url = "https://github.com/flodlol/Minecraft-Tierlist-Player-Generator/raw/main/Minecraft.ttf";
    sha256 = "0rfcba3lif3qk0jq0m4l2gmvfz33rzgjizwv216zyl0y616k2ixx";
  };

  barlow = pkgs.fetchurl {
    url = "https://github.com/google/fonts/raw/main/ofl/barlow/Barlow-SemiBold.ttf";
    sha256 = "1i8zpgw21xq0gs30qwznli8ng1g64510zjjkvdrkdgla5yrpqmw6";
  };

  comfortaa = pkgs.fetchurl {
    url = "https://github.com/google/fonts/raw/main/ofl/comfortaa/Comfortaa%5Bwght%5D.ttf";
    name = "Comfortaa-wght.ttf";
    sha256 = "1lsvdk4jp6c6b2rjzvlbpzn1fwmk8hjm10ciqfwlsqcbqifz9hqg";
  };

  # Helper to install fonts into a theme directory
  installThemeFonts = themeDir: ''
    mkdir -p ${themeDir}/terraria/font
    cp ${patrickHand} ${themeDir}/terraria/font/PatrickHand-Regular.ttf

    mkdir -p ${themeDir}/nier-automata/font
    cp ${twoWeekendGoSemibold} ${themeDir}/nier-automata/font/twoweekendgo-semibold.otf

    mkdir -p ${themeDir}/Genshin/font
    cp ${notoSansSC} ${themeDir}/Genshin/font/NotoSansSC-wght.ttf

    mkdir -p ${themeDir}/sword/font
    cp ${shojumaru} ${themeDir}/sword/font/Shojumaru-Regular.ttf

    mkdir -p ${themeDir}/minecraft/font
    cp ${minecraftFont} ${themeDir}/minecraft/font/Minecraft.ttf

    mkdir -p ${themeDir}/star-rail/font
    cp ${barlow} ${themeDir}/star-rail/font/Barlow-SemiBold.ttf

    mkdir -p ${themeDir}/osu/font
    cp ${comfortaa} ${themeDir}/osu/font/Comfortaa-wght.ttf

    mkdir -p ${themeDir}/osumania/font
    cp ${comfortaa} ${themeDir}/osumania/font/Comfortaa-wght.ttf
  '';
in
{
  qylock-sddm-theme = pkgs.stdenv.mkDerivation rec {
    pname = "qylock-sddm-theme";
    version = "1.0.0";

    src = ./.;

    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -r themes/* $out/share/sddm/themes/

      # Install font fallbacks
      ${installThemeFonts "$out/share/sddm/themes"}
    '';
  };

  qylock-sddm-theme-qt5 = pkgs.stdenv.mkDerivation rec {
    pname = "qylock-sddm-theme-qt5";
    version = "1.0.0";

    src = ./.;

    nativeBuildInputs = [ pkgs.perl ];

    buildPhase = ''
      patchShebangs qt5.sh
      ./qt5.sh
    '';

    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -r themes-qt5/* $out/share/sddm/themes/

      # Install font fallbacks
      ${installThemeFonts "$out/share/sddm/themes"}
    '';
  };

  qylock-lockscreen = pkgs.stdenv.mkDerivation rec {
    pname = "qylock-lockscreen";
    version = "1.0.0";

    src = ./.;

    nativeBuildInputs = [ pkgs.qt6.wrapQtAppsHook ];
    
    buildInputs = [
      pkgs.quickshell
      pkgs.qt6.qtwayland
      pkgs.qt6.qtmultimedia
      pkgs.qt6.qtsvg
      pkgs.qt6.qt5compat
      pkgs.qt6.qtdeclarative
    ];

    installPhase = ''
      mkdir -p $out/share/qylock-lockscreen
      cp -r quickshell-lockscreen/* $out/share/qylock-lockscreen/
      
      mkdir -p $out/share/qylock-lockscreen/themes
      cp -r themes/* $out/share/qylock-lockscreen/themes/
      
      # Install font fallbacks into lockscreen themes
      ${installThemeFonts "$out/share/qylock-lockscreen/themes"}

      mkdir -p $out/bin
      # Create a shim that calls quickshell with the right arguments
      cat > $out/bin/qylock-lock <<EOF
#!/bin/sh
# Add all Qt6 dependencies to QML2_IMPORT_PATH
export QML2_IMPORT_PATH="${pkgs.qt6.qtmultimedia}/lib/qt-6/qml:${pkgs.qt6.qt5compat}/lib/qt-6/qml:${pkgs.qt6.qtdeclarative}/lib/qt-6/qml:\$QML2_IMPORT_PATH"
exec ${pkgs.quickshell}/bin/quickshell -p "$out/share/qylock-lockscreen/lock_shell.qml" "\$@"
EOF
      chmod +x $out/bin/qylock-lock
    '';

    qtWrapperArgs = [
      "--prefix QML2_IMPORT_PATH : \"$out/share/qylock-lockscreen/imports\""
      "--set QML_XHR_ALLOW_FILE_READ \"1\""
      "--prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.procps pkgs.util-linux pkgs.systemd ]}"
    ];
  };
}
