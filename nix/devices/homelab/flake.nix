{
  description = "My NixOS Flake";

  inputs = {
    # nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs.url = "nixpkgs/nixos-25.05";
    stable.url = "nixpkgs/nixos-25.05";
    sops-nix.url = "github:Mic92/sops-nix";
    # fixed.url = "github:nixos/nixpkgs/97b17f32362e475016f942bbdfda4a4a72a8a652";
    fixed.url = "nixpkgs/nixos-25.05";

    hyprland = {
          url = "github:hyprwm/Hyprland?ref=v0.45.0";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, fixed, sops-nix, ... }@inputs: {
    nixosConfigurations = {
      "homelab" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit self inputs nixpkgs fixed;
        };
        modules = [
          {
            options.main-user = nixpkgs.lib.mkOption {
              type = nixpkgs.lib.types.str;
              default = "homelab";
            };
          }
          home-manager.nixosModules.home-manager
          ../../mypkgs/sops.nix
          ./homelab.nix
          ../../containers {
            containers1.interface = "enp1s0f1";
          }
          ../../mypkgs {
            mypkgs.neovim.enable = true;
            mypkgs.python.enable = true;
            mypkgs.tex.enable = true;
            mypkgs.networking = {
              enable = true;
              interface = "iwd";
              bluetooth.enable = false;
            };
          }
        ];
      };
    };
  };
}
