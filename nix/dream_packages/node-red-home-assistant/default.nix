{
  config,
  dream2nix,
  ...
}:
{
  imports = [
    dream2nix.modules.dream2nix.nodejs-granular-v3
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
  ];

  deps = {nixpkgs, ...}: {
    inherit
      (nixpkgs)
      fetchFromGitHub
      mkShell
      stdenv
      ;
  };

  nodejs-package-lock-v3 = {
    packageLockFile = "${config.mkDerivation.src}/package-lock.json";
  };

  name = "node-red-home-assistant";
  version = "0.65.2";
  mkDerivation = {
    src = config.deps.fetchFromGitHub {
      owner = "zachowj";
      repo = "node-red-contrib-home-assistant-websocket";
      rev = "v0.65.0";
      sha256 = "sha256-TVFX5n1IrysijOwbAbZRgpyyrjcL67bxEnXNC+hUBmY=";
    };
  };
}
