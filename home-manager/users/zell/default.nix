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
    # Add user-specific packages here
    ripgrep
    fd
    bat
    eza # modern ls replacement
    fzf
    htop
  ];

  # ── Shell ──────────────────────────────────────────────────────────────────
  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "eza";
      ll = "eza -lah";
      cat = "bat";
    };
    initExtra = ''
      # Host-aware prompt hint
      export NIX_HOST="${hostname}"
    '';
  };

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
