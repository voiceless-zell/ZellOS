{ ... }:

{
  imports = [
    ./nvim  # NVF-powered Neovim — system-wide (all users incl. root)
    ./sops.nix  # sops-nix secret decryption — system-wide
    # Add further shared NixOS modules here as the config grows
    # e.g. ./fonts.nix
    #      ./locale.nix
  ];
}
