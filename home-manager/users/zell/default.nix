{
  pkgs,
  lib,
  hostname,
  ...
}: {
  imports = [
    ../../modules
  ];

  # ── Identity ───────────────────────────────────────────────────────────────
  home = {
    username = "zell";
    homeDirectory = "/home/zell";
    stateVersion = "25.05";
  };

  # ── Packages ───────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # ── CLI tools ──────────────────────────────────────────────────────────
    ripgrep
    fd
    bat
    eza
    fzf
    htop
    neofetch
    unzip
    wget
    curl
    jq
    tree

    # ── Nix tools ──────────────────────────────────────────────────────────
    nix-tree
    nvd          # nix diff — compare generations
  ];

  # ── Zsh host env var ───────────────────────────────────────────────────────
  # Sets NIX_HOST so zsh and starship can show the current host if desired.
  programs.zsh.initExtra = ''
    export NIX_HOST="${hostname}"
  '';

  # ── Git ────────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user.name  = "Zell";
      user.email = "peter.bouchard2893@proton.me";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # ── Let home-manager manage itself ─────────────────────────────────────────
  programs.home-manager.enable = true;
}
