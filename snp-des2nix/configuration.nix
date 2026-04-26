# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
  ];
  sops.secrets.mend-password.neededForUsers = true;
  users.users.mend = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel"];
    hashedPasswordFile = config.sops.secrets.mend-password.path;
  };

  sops.secrets.snp-des2nix-key.owner = "nginx";
  sops.secrets.snp-des2nix-crt.owner = "nginx";

  environment.etc."nextcloud-admin-pass".text = "changeme";
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud33;
    hostName = "snp-des2nix.tailf46592.ts.net";
    https = true;
    database.createLocally = true;
    config.adminpassFile = "/etc/nextcloud-admin-pass";
    config.dbtype = "pgsql";
    settings = {
      maintenance_window_start = 5;
    };
    phpOptions = {
      "opcache.interned_strings_buffer" = "16"; # make a warning go away
    };
  };
  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;

    sslCertificate = config.sops.secrets.snp-des2nix-crt.path;
    sslCertificateKey = config.sops.secrets.snp-des2nix-key.path;

    # your cat said oh no no no girl don't even think about it
    enableACME = false;
  };

  networking.firewall.allowedTCPPorts = [80 443];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "snp-des2nix";

  programs.ssh = {
    extraConfig = ''
      Host snp-nuc1nix
      	Hostname 192.168.30.65
      	Port 22
      	User mend
      Host localgit
      	Hostname localhost
      	User git
      	IdentityFile ~/.ssh/id_ed25519
      	IdentitiesOnly yes
    '';
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
    };
    extraConfig = ''
      Match user git
      AllowTcpForwarding no
      AllowAgentForwarding no
      PasswordAuthentication no
      PermitTTY no
      X11Forwarding no
    '';
  };

  # git on the server ! - https://nixos.wiki/wiki/Git
  users.users.git = {
    isSystemUser = true;
    group = "git";
    home = "/var/lib/git-server";
    createHome = true;
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILywcKsOrkjA6Zz0Nzv4zSkVSc67Yp8e1FZZql7AETTLAAAABHNzaDo= snuppy.code@pm.me"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDkgmUlpM3cGE0MDHU0QyCtspkpImLjQVpkU7ihv5P9 mend@snp-des2nix"
    ];
  };
  users.groups.git = {};

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
