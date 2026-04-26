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
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # -
    # > An important note to take is that the option hardware.nvidia.open should only be set to false if you have a GPU with an older architecture than Turing (older than the RTX 20-Series). Also, OBS NVENC support does not seem to work currently with the open drivers.
    open = true; # so I guess I want it anyway?

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };
}
