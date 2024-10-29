{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "nixos";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEW00/jbuENN0WsJ82jLoeUJSgaKpEgNwSdvwNRRKK7y agatasumowska@Agatas-MacBook-Pro.local'' ''# Added and Managed by DigitalOcean Droplet Agent (code name: DOTTY)'' ''ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOwLXzBu/+nJ74351md3MNorTsmWi1/l29stwbqp42MQXvRVXiub11H0w0ytUCmi+i7HXVmMxzSI0lMjTaXgPcA= {os_user:root,actor_email:agata.sumowska@gmail.com,expire_at:2024-10-27T14:31:05Z}-dotty_ssh'' ];
  system.stateVersion = "23.11";
}
