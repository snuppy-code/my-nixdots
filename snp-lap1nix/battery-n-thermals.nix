{
  config,
  pkgs,
  inputs,
  ...
}: {
  powerManagement.enable = true; #https://nixos.wiki/wiki/Laptop
  services.thermald.enable = true;
  # https://github.com/NixOS/nixos-hardware/blob/master/lenovo/yoga/7/14IAH7/shared.nix
  boot.kernelParams = [
    "pcie_aspm.policy=powersupersave"
    "mem_sleep_default=deep"
  ];
  services.power-profiles-daemon.enable = false; # KDE and Gnome both enable this one, so I disable it to instead use tlp
  services.tlp.enable = true;
  services.tlp.settings = {
    #mostly settings making it throttle on battery and not on AC
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

    CPU_MIN_PERF_ON_AC = 0;
    CPU_MAX_PERF_ON_AC = 100;
    CPU_MIN_PERF_ON_BAT = 0;
    CPU_MAX_PERF_ON_BAT = 20;

    # maybe slightly help battery life
    START_CHARGE_THRESH_BAT0 = 40;
    STOP_CHARGE_THRESH_BAT0 = 80;
  };
}