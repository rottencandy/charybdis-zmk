{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zmk-nix }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
  in {
    packages = forAllSystems (system: rec {
      default = firmware;

      firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        name = "char";
        src = nixpkgs.lib.sourceFilesBySuffices self [ ".board" ".cmake" ".conf" ".defconfig" ".dts" ".dtsi" ".json" ".keymap" ".overlay" ".shield" ".yml" "_defconfig" ];

        # boards
        board = "nice_nano_v2";
        shield = "charybdis_%PART%";
        parts = [ "left" "right" ];
        # enable for dongle build
        #extraCmakeFlags = [ "-DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n" ];

        # dongle
        #board = "nice_nano_v2";
        #shield = "charybdis_%PART%";
        #parts = [ "dongle" ];
        #extraCmakeFlags = [ "-DCONFIG_ZMK_STUDIO=y" ];

        # bt settings reset
        #board = "nice_nano_v2";
        #shield = "settings_reset";
        #parts = [ "left" "right" "dongle" ];

        enableZmkStudio = true;
        zephyrDepsHash = "sha256-BV9nDRzMhr5CRwmjUEy6wfJ8sh0vNUZivjfBzC2BHF4=";

        meta = {
          description = "ZMK firmware";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };

      flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}
