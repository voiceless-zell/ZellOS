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

    initExtra = "";

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
