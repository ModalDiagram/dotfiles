{
  description = "My NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland"; # where {version} is the hyprland release version
    # or "github:hyprwm/Hyprland" to follow the development branch

    hy3 = {
      url = "github:outfoxxed/hy3"; # where {version} is the hyprland release version
      # or "github:outfoxxed/hy3" to follow the development branch.
      # (you may encounter issues if you dont do the same for hyprland)
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, hy3, ... }@inputs: {
    nixosConfigurations = {
      "sandro0198" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Import the configuration.nix here, so that the
          # old configuration file can still take effect.
          # Note: configuration.nix itself is also a Nixpkgs Module,
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = { inherit hyprland hy3; };
            home-manager.users.sandro0198 = import ./homemanager.nix;
          }
        ];
      };
    };
  };
}
