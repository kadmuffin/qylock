{
  description = "qylock - SDDM & Quickshell lockscreen themes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "i686-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs supportedSystems;
    in {
      packages = forEachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          qylock-packages = import ./default.nix { inherit pkgs; };
        in qylock-packages // {
          default = qylock-packages.qylock-sddm-theme;
        }
      );

      nixosModules = {
        qylock = { config, lib, pkgs, ... }:
          let
            cfg = config.services.qylock;
            qylock-pkgs = self.packages.${pkgs.system};
          in {
            options.services.qylock = {
              enable = lib.mkEnableOption "qylock SDDM themes";
              theme = lib.mkOption {
                type = lib.types.str;
                default = "nier-automata";
                description = "The qylock theme to use (e.g., 'nier-automata', 'pixel-coffee', 'terraria').";
              };
              qtVersion = lib.mkOption {
                type = lib.types.enum [ "5" "6" ];
                default = "6";
                description = "Qt version of SDDM theme (6 for modern Qt6, 5 for legacy Qt5).";
              };
              themeConfig = lib.mkOption {
                type = lib.types.attrsOf lib.types.str;
                default = {};
                description = "Key-value pairs to override settings in the theme's theme.conf.";
              };
            };

            config = lib.mkIf cfg.enable {
              services.displayManager.sddm = {
                enable = true;
                theme = cfg.theme;
                extraPackages = if cfg.qtVersion == "6" then [
                  pkgs.qt6.qt5compat
                  pkgs.qt6.qtsvg
                  pkgs.qt6.qtmultimedia
                ] else [
                  pkgs.libsForQt5.qtgraphicaleffects
                  pkgs.libsForQt5.qtquickcontrols2
                  pkgs.libsForQt5.qtmultimedia
                ];
              };

              environment.systemPackages = [
                (let
                  basePackage = if cfg.qtVersion == "6" then qylock-pkgs.qylock-sddm-theme else qylock-pkgs.qylock-sddm-theme-qt5;
                in
                  if cfg.themeConfig == {} then basePackage
                  else pkgs.stdenv.mkDerivation {
                    pname = "qylock-sddm-theme-customized";
                    version = basePackage.version;
                    src = basePackage;
                    installPhase = ''
                      mkdir -p $out/share/sddm/themes
                      cp -r share/sddm/themes/* $out/share/sddm/themes/
                      chmod -R +w $out/share/sddm/themes/
                      
                      CONF_FILE="$out/share/sddm/themes/${cfg.theme}/theme.conf"
                      if [ -f "$CONF_FILE" ]; then
                        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (key: val: ''
                          if grep -q "^${key}=" "$CONF_FILE"; then
                            sed -i "s|^${key}=.*|${key}=${val}|" "$CONF_FILE"
                          else
                            echo "${key}=${val}" >> "$CONF_FILE"
                          fi
                        '') cfg.themeConfig)}
                      fi
                    '';
                  }
                )
              ];
            };
          };
        
        default = self.nixosModules.qylock;
      };
    };
}
