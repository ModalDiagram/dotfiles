{
  description = "My NixOS Flake";

  inputs = {
    # nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs.url = "nixpkgs/nixos-25.05";
    stable.url = "nixpkgs/nixos-25.05";
    sops-nix.url = "github:Mic92/sops-nix";
    # fixed.url = "github:nixos/nixpkgs/97b17f32362e475016f942bbdfda4a4a72a8a652";
    fixed.url = "nixpkgs/nixos-24.11";

    hyprland = {
          url = "github:hyprwm/Hyprland?ref=v0.45.0";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, fixed, sops-nix, hyprland, ... }@inputs:
  let system = "x86_64-linux"; in {
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
          ../../mypkgs/sops.nix
          ./lenovo.nix
          ../../mypkgs {
            mypkgs.hyprland.enable = true;
            mypkgs.neovim.enable = true;
            mypkgs.python.enable = true;
            mypkgs.networking = {
              enable = true;
              interface = "networkmanager";
            };
            mypkgs.theme = {
              enable = true;
              name = "nature";
            };
            mypkgs.rlang.enable = true;
            mypkgs.sql.enable = true;
            mypkgs.tex.enable = false;
            mypkgs.misc.enable = true;
          }
        ];
      };
    };
  };
}
