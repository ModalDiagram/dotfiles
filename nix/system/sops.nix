{ pkgs, inputs, ... }: {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  config = {
    environment.systemPackages = [ pkgs.sops pkgs.ssh-to-age ];

    # sops.defaultSopsFile = "../secrets/secrets.json";
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    sops.secrets."network.env" = { sopsFile = ../secrets/network.env; format = "dotenv"; };
    sops.secrets.nextcloud_password = { sopsFile = ../secrets/containers.json; format = "json"; };
    sops.secrets.paperless_password = { sopsFile = ../secrets/containers.json; format = "json"; };
  };
}
