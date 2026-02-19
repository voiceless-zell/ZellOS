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

  # ── SSH ────────────────────────────────────────────────────────────────────
  # Enabled primarily to generate and persist /etc/ssh/ssh_host_ed25519_key,
  # which sops-nix derives the host age key from. Password auth is off;
  # root login is off. WSL does not expose this port to the network by default.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
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
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
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
    zsh
  ];
}
