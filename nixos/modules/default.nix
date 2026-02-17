{ ... }:

{
  imports = [
    ./nvim  # NVF-powered Neovim — system-wide (all users incl. root)
    # Add further shared NixOS modules here as the config grows
    # e.g. ./fonts.nix
    #      ./locale.nix
  ];
}
