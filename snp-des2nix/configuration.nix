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

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 14d --keep 10";
    flake = "/home/mend/.dots";
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
      log_type = "file";
      loglevel = 0;
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

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    8920 # jellyfin (via nginx vhost)
  ];
  networking.firewall.allowedTCPPorts = [80 443];

  services.jellyfin.enable = true;

  systemd.tmpfiles.rules = [
    "d /srv/media 0755 mend users -"
    "d /srv/media/movies 0755 mend users -"
  ];

  services.nginx.virtualHosts."jellyfin" = {
    serverAliases = ["snp-des2nix.tailf46592.ts.net"];
    onlySSL = true;
    listen = [
      {
        addr = "0.0.0.0";
        port = 8920;
        ssl = true;
      }
    ];
    sslCertificate = config.sops.secrets.snp-des2nix-crt.path;
    sslCertificateKey = config.sops.secrets.snp-des2nix-key.path;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8096";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
      '';
    };
  };

  programs.ssh = {
    extraConfig = ''
      Host snp-nuc1nix
      	Hostname 192.168.30.65
      	Port 22
      	User mend
    '';
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      AllowUsers = ["mend" "del"];
    };
  };
  users.users.mend.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIL6GdZbeYiKswMnNEhq6vSSJt4xzXDTFpUbxJ87JD/LuAAAABHNzaDo= bunyaminlkeser@gmail.com"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKULoTLRUxXh/H32tYRncHD4KGxXZC2lUryf0X5w6QMPAAAABHNzaDo= snuppy.code@pm.me"
  ];

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
