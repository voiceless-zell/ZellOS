{ inputs, hostname, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
  ];

  # ── Boot ───────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── CPU microcode ──────────────────────────────────────────────────────────
  # __CPU_MICROCODE__

  # ── GPU ────────────────────────────────────────────────────────────────────
  # __GPU_CONFIG__

  # ── Networking ─────────────────────────────────────────────────────────────
  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  # __WIFI_CONFIG__

  # ── SSH ────────────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # ── Locale & time ──────────────────────────────────────────────────────────
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── System ─────────────────────────────────────────────────────────────────
  system.stateVersion = "25.05";

  # ── Nix settings ───────────────────────────────────────────────────────────
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # ── Users ──────────────────────────────────────────────────────────────────
  users.users.__USERNAME__ = {
    isNormalUser = true;
    description = "__USERNAME__";
    extraGroups = [ "wheel" "networkmanager" "__EXTRA_GROUPS__" ];
    shell = pkgs.bash;
  };

  security.sudo.extraRules = [
    {
      users = [ "__USERNAME__" ];
      commands = [
        { command = "ALL"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

  # ── Home Manager ───────────────────────────────────────────────────────────
  home-manager.users.__USERNAME__ = import ../../../home-manager/users/__USERNAME__;

  # ── Global packages ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
  ];
}
