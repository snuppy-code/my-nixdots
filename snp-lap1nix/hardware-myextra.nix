{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  boot.kernelPackages = pkgs.linuxPackages_latest; # latest kernel
  boot.kernelModules = ["kvm-intel"];
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "snp-lap1nix";

  # https://wiki.nixos.org/wiki/Accelerated_Video_Playback
  # https://nixos.wiki/wiki/Intel_Graphics
  # https://wiki.nixos.org/wiki/Intel_Graphics
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime # for openCL, optional
      intel-media-driver
      vpl-gpu-rt
    ];
  };
  environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";}; #unsure if this is right?

  # Resolves return from sleep on Wi-Fi 7 BE200 (Gale Peak 2). This is from gemini :/ because I wasn't able to solve this on my own and this solves my issue.
  services.udev.extraRules = ''ACTION=="add|bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x272b", ATTR{d3cold_allowed}="0"'';
}