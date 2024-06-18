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

  name = "node-red-contrib-sunevents";
  version = "3.1.0";
  mkDerivation = {
    src = config.deps.fetchFromGitHub {
      owner = "freakent";
      repo = "node-red-contrib-sunevents";
      rev = "v3.1.0";
      sha256 = "sha256-xCmxyWN1IStI+Vm+zEQA30FzLJMBfO0aUb/E3EZArPc=";
    };
  };
}
