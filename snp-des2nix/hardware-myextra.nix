{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  # set of desireable kernels that are compatible with zfs
  zfsCompatibleKernelPackages =
    lib.filterAttrs (
      kernelPackageName: kernelPackage:
      # filters to kernels like linux_6_6, excludes kernels like linux_zen
        (builtins.match "linux_[0-9]+_[0-9]+" kernelPackageName)
        != null
        # filters to only kernels that are supported for this system
        && (builtins.tryEval kernelPackage).success
        # filters to only kernels that ZFS builds against
        && (!kernelPackage.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
    )
    pkgs.linuxKernel.packages;

  # gets bottom element, the newest kernel from zfsCompatibleKernelPackages
  newZfsYumKernelPackage = lib.last (
    # sorts ascending by age (top is oldest)
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      # drops the names, turns attrset into list
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = ["usbhid" "usb_storage"];

  # Would be needed if x11 or wayland, but this server is headless for now.
  # services.xserver.videoDrivers = ["nvidia"];

  # nixpkgs.config.cudaSupport = true; # later !
  hardware.graphics.enable = true;
  hardware.nvidia.open = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_535; # or 470 or 580
  hardware.nvidia.modesetting.enable = true;

  boot.kernelPackages = newZfsYumKernelPackage;

  boot.supportedFilesystems = ["zfs"];
  boot.zfs.extraPools = ["tank"];

  networking.hostName = "snp-des2nix";
  networking.hostId = "c90f3653";

  fileSystems."/export/zfs" = {
    device = "tank/terminaldogma";
    fsType = "zfs";
  };

  fileSystems."/tank" = {
    device = "tank";
    fsType = "zfs";
  };

  fileSystems."/mnt/secondbranch" = {
    device = "tank/terminaldogma/secondbranch";
    fsType = "zfs";
  };
}
