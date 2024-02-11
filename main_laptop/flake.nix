{
  description = "My NixOS Flake";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs.url = "nixpkgs/nixos-23.11";
    stable.url = "nixpkgs/nixos-23.11";
    fixed.url = "github:nixos/nixpkgs/97b17f32362e475016f942bbdfda4a4a72a8a652";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, fixed, ... }@inputs:{
    nixosConfigurations = {
      "sandro0198" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        specialArgs = { inherit self system inputs nixpkgs fixed; };
        modules = [
          {options.main-user = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.str;
            default = "sandro0198";
          }; }
          home-manager.nixosModules.home-manager {
            # home-manager.users."sandro0198".home.stateVersion = "23.11";
            home-manager.users."sandro0198" = import ./homemanager.nix;
          }
          ./configuration.nix
          ../nix-modules/system/user.nix
          ../nix-modules/system/networking.nix
          ../nix-modules/misc
          ../nix-modules/hyprland
          ../nix-modules/neovim
          ../nix-modules/python
        ];
      };
    };
  };
}
