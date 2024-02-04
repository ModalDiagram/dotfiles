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
    nixpkgs.url = "nixpkgs/nixos-unstable";
    stable.url = "nixpkgs/nixos-23.11";
    fixed.url = "github:nixos/nixpkgs/97b17f32362e475016f942bbdfda4a4a72a8a652";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland ={
      url = "github:hyprwm/Hyprland"; # where {version} is the hyprland release version
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-hy3 = {
      url = "github:outfoxxed/hy3"; # where {version} is the hyprland release version
      # or "github:outfoxxed/hy3" to follow the development branch.
      # (you may encounter issues if you dont do the same for hyprland)
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, hyprland-hy3, fixed, ... }@inputs:{
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
