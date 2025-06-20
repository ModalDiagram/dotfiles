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
    dream2nix.url = "github:nix-community/dream2nix";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, fixed, dream2nix, sops-nix, ... }@inputs:
  let system = "x86_64-linux"; in {
    nixosConfigurations = {
      "homelab" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        specialArgs = {
          inherit self system inputs nixpkgs fixed dream2nix;
          node-red-contrib-sunevents = self.packages.x86_64-linux.node-red-contrib-sunevents;
          node-red-home-assistant = self.packages.x86_64-linux.node-red-home-assistant;
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

    packages.${system} = dream2nix.lib.importPackages {
      projectRoot = ../../.;
      # can be changed to ".git" or "flake.nix" to get rid of .project-root
      projectRootFile = "flake.nix";
      packagesDir = ../../mypkgs/dream_packages;
      packageSets.nixpkgs = nixpkgs.legacyPackages.${system};
    };
  };
}
