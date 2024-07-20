{
  description = "My NixOS Flake";

  inputs = {
    # nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs.url = "nixpkgs/nixos-24.05";
    stable.url = "nixpkgs/nixos-24.05";
    sops-nix.url = "github:Mic92/sops-nix";
    # fixed.url = "github:nixos/nixpkgs/97b17f32362e475016f942bbdfda4a4a72a8a652";
    fixed.url = "nixpkgs/nixos-24.05";

    dream2nix.url = "github:nix-community/dream2nix";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, fixed, dream2nix, sops-nix, ... }@inputs:
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
          ../../system/sops.nix
          ../../specific/lenovo.nix
          ../../mypkgs {
            mypkgs.hyprland.enable = true;
            mypkgs.neovim.enable = true;
            mypkgs.python.enable = true;
            mypkgs.networking = {
              enable = true;
              interface = "wpa_supplicant";
            };
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
