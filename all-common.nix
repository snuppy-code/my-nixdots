{
  config,
  pkgs,
  inputs,
  ...
}: {
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=120 # only ask for passwd every 120min
  '';

  # todo find out a nice way to make my devices share lockfile but also update it automatically
  # also maybe DO have them pull automatically? I can work on feature branches when fucking around and breaking shit Ig

  # system.autoUpgrade = {
  #   enable = true;
  #   dates = "15:00";
  #   allowReboot = false; # don't destroy my work !
  #   flake = "github:snuppy-code/my-nixdots";
  #   flags = [
  #     "--update-input" "nixpkgs"
  #     "--commit-lock-file"
  #   ];
  #   operation = "switch";
  #   runGarbageCollection = true;
  # };

  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      user.name = "snuppy";
      user.email = "snuppy.code@pm.me";
    };
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {inherit inputs;};
  home-manager.backupFileExtension = "backup";
  # I specify this in the flake instead cuz this file also goes for snp-lap1nix and snp-des2nix
  # home-manager.users.snuppy = import ./snp-des1nix/snuppy-home.nix;
  # I specify this in the flake instead cuz this file also goes for snp-des2nix
  # mycli.username = "snuppy";

  time.timeZone = "Europe/Oslo";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nb_NO.UTF-8";
    LC_IDENTIFICATION = "nb_NO.UTF-8";
    LC_MEASUREMENT = "nb_NO.UTF-8";
    LC_MONETARY = "nb_NO.UTF-8";
    LC_NAME = "nb_NO.UTF-8";
    LC_NUMERIC = "nb_NO.UTF-8";
    LC_PAPER = "nb_NO.UTF-8";
    LC_TELEPHONE = "nb_NO.UTF-8";
    LC_TIME = "nb_NO.UTF-8";
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.smartd.enable = true; # SMART Daemon
  services.fstrim.enable = true; # important !
  services.tailscale.enable = true;
  services.openssh.enable = true;
  networking.networkmanager.enable = true;

  # Gemini :/ says this makes nixos continue to get latest closed source firmware
  # configuring my laptop I found this too: # https://github.com/NixOS/nixos-hardware/blob/master/lenovo/yoga/7/slim/gen8/default.nix
  hardware.enableRedistributableFirmware = true;

  sops = {
    defaultSopsFile = ./secrets.yaml;
    validateSopsFiles = false; # https://youtu.be/gdxlc5a6ne0 his was false
    age = {
      # I generated keys from all my hosts' public ssh host keys and added them to .sops.yaml
      # Here I tell sops-nix(?) about this host's private ssh host key so it can import it automatically as an age key
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      # this is where it will store the converted/imported age key
      keyFile = "/var/lib/sops-nix/key.txt";
      # generate a key from the sshKeyPaths if the key specified above doesn't exist
      generateKey = true;
    };
    # Secrets get output to /run/secrets unencrypted but only accessible to root -
    #  until we specify otherwise.
    # E.g. /run/secrets/msmtp-password
    # Secrets required for user creation need to be handled slightly differently -
    #  since sops-nix normally runs after users have been created by nixos so    -
    #  appropriate ownership/permissions can be set, but this can't happen for   -
    #  user passwords, because the user will already have been created.
    # The provided solution is setting neededForUsers, it will extract to        -
    # /run/secrets-for-users before user creation. Owners can't be set           -
    # for those files:
    # ```
    # secrets = {
    #     snuppy-password.neededForUsers = true;
    # };
    # ```
    # And later reference as, in this case, `config.sops.secrets.snuppy-password.path`
  };
  # Makes the passwords of users be controlled only by nixos config
  # Required to set passwords with sops-nix
  # BE CAREFUL WITH THIS! IT BITES! CAN AND WILL LOCK YOU OUT OF YOUR SERVER!
  users.mutableUsers = false;
}
