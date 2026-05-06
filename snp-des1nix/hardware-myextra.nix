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
  hardware.graphics = {
    enable = true; # installs the appropriate `mesa` OpenGL driver, most DEs set this already apparently
    extraPackages = {
      # additional driver packages can be added here. e.g. OpenCL is not default in `mesa`, can be added here
      # I get OpenCL from my nvidia drivers
    };
  };
  nixpkgs.config.cudaSupport = true; # enables CUDA support for *packages* by default

  # https://wiki.nixos.org/wiki/Graphics
  # mesa includes OpenGL, Vulkan drivers, and hardware video acceleration
  # "Kernel-level GPU support is provided by a kernel module [...]"
  # "[...] The module is loaded automatically based on the detected hardware. On x86 devices, detection is done automatically through ACPI."
  # "Normally, the kernel module is loaded and KMS is performed after the initrd stage ("late KMS"), i.e. after entering the encryption password if you use full disk encryption. This will produce some flickering."
  # "The kernel module can also be added to the initrd itself ("early KMS") by adding the kernel module for your hardware to boot.initrd.kernelModules. Early KMS is especially desirable when using something like Plymouth for flicker-free fancy graphics during boot. If you don't use Plymouth, early KMS might actually make the boot sequence worse, because the flicker might heppen during encryption password entry."
  boot.initrd.kernelModules = [
    # The set of kernel modules in the initial ramdisk used during the boot process
    # Arch wiki/nvidia: "Early loading the modules will break hibernation, as video memory preservation is enabled by default."
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

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
