{
  config,
  dream2nix,
  ...
}:
{
  imports = [
    dream2nix.modules.dream2nix.nodejs-node-modules-v3
    dream2nix.modules.dream2nix.nodejs-package-json-v3
  ];

  deps = {nixpkgs, ...}: {
    inherit
      (nixpkgs)
      fetchFromGitHub
      mkShell
      stdenv
      ;
  };

  nodejs-package-json = {
    source = config.deps.fetchFromGitHub {
      owner = "zachowj";
      repo = "node-red-contrib-home-assistant-websocket";
      rev = "v0.64.0";
      sha256 = "sha256-TVFX5n1IrysijOwbAbZRgpyyrjcL67bxEnXNC+hUBmY=";
    };
  };
  nodejs-package-lock-v3 = {
    packageLockFile = "${config.mkDerivation.src}/package-lock.json";
  };

  name = "node-red-home-assistant";
  version = "0.65.2";
  mkDerivation = {
    src = config.nodejs-package-json.source;
  };
}
