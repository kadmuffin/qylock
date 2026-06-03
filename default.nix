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

  copyFonts = dst: ''
    mkdir -p ${dst}/terraria/font
    cp ${patrickHand} ${dst}/terraria/font/PatrickHand-Regular.ttf

    mkdir -p ${dst}/nier-automata/font
    cp ${twoWeekendGoSemibold} ${dst}/nier-automata/font/twoweekendgo-semibold.otf

    mkdir -p ${dst}/Genshin/font
    cp ${notoSansSC} ${dst}/Genshin/font/NotoSansSC-wght.ttf

    mkdir -p ${dst}/sword/font
    cp ${shojumaru} ${dst}/sword/font/Shojumaru-Regular.ttf

    mkdir -p ${dst}/minecraft/font
    cp ${minecraftFont} ${dst}/minecraft/font/Minecraft.ttf

    mkdir -p ${dst}/star-rail/font
    cp ${barlow} ${dst}/star-rail/font/Barlow-SemiBold.ttf

    mkdir -p ${dst}/osu/font
    cp ${comfortaa} ${dst}/osu/font/Comfortaa-wght.ttf

    mkdir -p ${dst}/osumania/font
    cp ${comfortaa} ${dst}/osumania/font/Comfortaa-wght.ttf
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
      ${copyFonts "$out/share/sddm/themes"}
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
      ${copyFonts "$out/share/sddm/themes"}
    '';
  };
}
