{ ... }:

{
  imports = [
    # sops.nix is loaded via flake sharedModules — do not import here
    ./zsh.nix      # zsh with oh-my-zsh
    ./starship.nix # cross-shell prompt
    # Add shared home-manager modules here as you create them
    # e.g. ./tmux.nix
  ];
}
