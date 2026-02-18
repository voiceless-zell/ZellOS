{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    # nixos-generate-config output will be merged here by the install script
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ── Boot filesystem & initrd ───────────────────────────────────────────────
  # Populated by nixos-generate-config during install — do not edit by hand.
  # __HARDWARE_CONFIG__

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [ "kvm-__CPU_KMOD__" ];  # kvm-intel or kvm-amd
  boot.extraModulePackages = [];

  # ── Filesystems ────────────────────────────────────────────────────────────
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];

  # ── Platform ───────────────────────────────────────────────────────────────
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # __VM_CONFIG__
}
