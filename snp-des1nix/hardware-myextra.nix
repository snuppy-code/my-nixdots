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

  services.xserver.videoDrivers = ["nvidia"]; # installs nvidia drivers to the system. incl. OpenCL and CUDA
  hardware.nvidia = {
    modesetting.enable = true; # KMS, needed for wayland
    open = true; # use open source kernel module instead of noveau
    package = config.boot.kernelPackages.nvidiaPackages.stable; # {production,stable,beta} as of writing

    powerManagement.finegrained = false;
    nvidiaSettings = true; # official gui with info & settings

    powerManagement.enable = true; # can fix resume-from-suspend issues
  };
  powerManagement.enable = true; # can fix resume from suspend -issues
  # mesa includes OpenGL, Vulkan drivers, and hardware video acceleration
  hardware.graphics = {
    enable = true; # installs the appropriate mesa driver, most DEs set this already apparently
    extraPackages = [
      # additional driver packages can be added here. e.g. OpenCL is not default in `mesa`, can be added here
      # I get OpenCL from my nvidia drivers
    ];
  };
  nixpkgs.config.cudaSupport = true; # enables CUDA support for *packages* by default
  boot.initrd.kernelModules = [
    # The set of kernel modules in the initial ramdisk used during the boot process
    # good for less flickering of plymouth, bad otherwise?
    # Arch wiki says this will break hibernation, "as video memory preservation is enabled by default."
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];
}
