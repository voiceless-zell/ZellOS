{ ... }:

{
  imports = [
    ./sops.nix  # sops-nix user secret deployment
    # Add shared home-manager modules here as you create them
    # e.g. ./neovim.nix
    #      ./tmux.nix
    #      ./starship.nix
  ];
}
