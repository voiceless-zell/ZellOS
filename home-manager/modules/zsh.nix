{ ... }:

# ── Zsh — shell configuration ─────────────────────────────────────────────────
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [];
    };

    initExtra = ''
      # ── Post-install instructions (shows once then deletes itself) ──────────
      if [ -f "$HOME/ZellOS/POST_INSTALL.md" ]; then
        cat "$HOME/ZellOS/POST_INSTALL.md"
        rm "$HOME/ZellOS/POST_INSTALL.md"
      fi
    '';

    shellAliases = {
      # ── Nix ────────────────────────────────────────────────────────────────
      ncg = "nix-collect-garbage && nix-collect-garbage -d && sudo nix-collect-garbage && sudo nix-collect-garbage -d && sudo rm /nix/var/nix/gcroots/auto/*";

      # ── Navigation ─────────────────────────────────────────────────────────
      fl    = "cd ~/ZellOS/ && nvim";
      notes = "cd ~/notes/ && nvim";

      # ── Tools ──────────────────────────────────────────────────────────────
      n   = "clear && neofetch";
      v   = "nvim";
      ls  = "eza --icons --long";
      ll  = "eza --icons --long --all";
      cat = "bat";
    };
  };
}
