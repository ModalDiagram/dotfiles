{
  description = "My NixOS Flake";

  inputs = {
    # nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs.url = "nixpkgs/nixos-25.05";
    stable.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";
    fixed.url = "nixpkgs/nixos-24.11";

    hyprland = {
          url = "github:hyprwm/Hyprland?ref=v0.45.0";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/beta";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, fixed, sops-nix, ... }@inputs: {
    nixosConfigurations = {
      "lenovo" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit self inputs nixpkgs nixpkgs-unstable fixed; };
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
              name = "xmas";
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
