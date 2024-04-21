{
  description = "My NixOS Flake";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org" "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    # nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs.url = "nixpkgs/nixos-23.11";
    stable.url = "nixpkgs/nixos-23.11";
    # fixed.url = "github:nixos/nixpkgs/97b17f32362e475016f942bbdfda4a4a72a8a652";
    fixed.url = "nixpkgs/nixos-23.11";

    hyprland = {
      url = "github:hyprwm/Hyprland?ref=v0.39.1";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, fixed, hyprland, ... }@inputs:{
    nixosConfigurations = {
      "lenovo" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        specialArgs = { inherit self system inputs nixpkgs fixed; };
        modules = [
          {
            options.main-user = nixpkgs.lib.mkOption {
              type = nixpkgs.lib.types.str;
              default = "sandro0198";
            };
          }
          home-manager.nixosModules.home-manager
          ./specific/lenovo.nix
          ./mypkgs {
            mypkgs.hyprland.enable = true;
            mypkgs.neovim.enable = true;
            mypkgs.python.enable = true;
            mypkgs.networking.interface = "wpa_supplicant";
            mypkgs.rlang.enable = true;
            mypkgs.sql.enable = true;
            mypkgs.tex.enable = true;
            mypkgs.misc.enable = true;
          }
        ];
      };
    };
  };
}
