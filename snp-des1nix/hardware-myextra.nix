{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  networking.hostName = "snp-des1nix";
  networking.hostId = "7d1d9835";

  boot.supportedFilesystems = ["zfs"];
  boot.zfs.extraPools = ["tank"];

  boot.kernelModules = ["kvm-amd"];
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.graphics = {
    enable = true;
  };
  services.xserver.videoDrivers = ["nvidia"];
  powerManagement.enable = true; # powerManagement.enable = true can sometimes fix this, but is itself unstable and is known to cause suspend issues.
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with noveau or whatever
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable; # production was the last one
  };
  # # https://discourse.nixos.org/t/black-screen-after-suspend-hibernate-with-nvidia/54341/6
  # # https://discourse.nixos.org/t/suspend-problem/54033/28
  # systemd = {
  #   # Uncertain if this is still required or not.
  #   services.systemd-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
  #
  #   services."gnome-suspend" = {
  #     description = "suspend gnome shell";
  #     before = [
  #       "systemd-suspend.service"
  #       "systemd-hibernate.service"
  #       "nvidia-suspend.service"
  #       "nvidia-hibernate.service"
  #     ];
  #     wantedBy = [
  #       "systemd-suspend.service"
  #       "systemd-hibernate.service"
  #     ];
  #     serviceConfig = {
  #       Type = "oneshot";
  #       ExecStart = ''${pkgs.procps}/bin/pkill -f -STOP ${pkgs.gnome-shell}/bin/gnome-shell'';
  #     };
  #   };
  #   services."gnome-resume" = {
  #     description = "resume gnome shell";
  #     after = [
  #       "systemd-suspend.service"
  #       "systemd-hibernate.service"
  #       "nvidia-resume.service"
  #     ];
  #     wantedBy = [
  #       "systemd-suspend.service"
  #       "systemd-hibernate.service"
  #     ];
  #     serviceConfig = {
  #       Type = "oneshot";
  #       ExecStart = ''${pkgs.procps}/bin/pkill -f -CONT ${pkgs.gnome-shell}/bin/gnome-shell'';
  #     };
  #   };
  # };
}
