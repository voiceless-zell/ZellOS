{ pkgs, ... }:

{
  imports = [
    ./nvim     # NVF-powered Neovim — system-wide (all users incl. root)
    ./sops.nix # sops-nix secret decryption — system-wide
    # Add further shared NixOS modules here as the config grows
    # e.g. ./locale.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Required for zsh to be a valid login shell on NixOS
  programs.zsh.enable = true;

  # ── Fonts ──────────────────────────────────────────────────────────────────
  # Nerd Fonts provide the icon glyphs used by starship, nvim, zsh, and eza.
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs.nerd-fonts; [
      jetbrains-mono  # primary coding font with full nerd font symbols
      fira-code       # alternative with ligatures
      noto-sans       # fallback for broad unicode coverage
    ];
    fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "JetBrainsMono Nerd Font" "FiraCode Nerd Font" ];
    };
  };
}
