{ inputs, hostname, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
  ];

  # ── WSL ────────────────────────────────────────────────────────────────────
  wsl = {
    enable = true;
    defaultUser = "zell";
  };

  # ── System ─────────────────────────────────────────────────────────────────
  networking.hostName = hostname; # "wsl"

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
  users.users.zell = {
    isNormalUser = true;
    description = "Zell";
    extraGroups = [ "wheel" ];
    shell = pkgs.bash; # change to pkgs.zsh, pkgs.fish, etc. as desired
  };

  # Allow zell to use sudo without password (common WSL convenience)
  security.sudo.extraRules = [
    {
      users = [ "zell" ];
      commands = [
        { command = "ALL"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

  # ── Home Manager ───────────────────────────────────────────────────────────
  home-manager.users.zell = import ../../../home-manager/users/zell;

  # ── Global packages ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
  ];
}
