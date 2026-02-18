{ ... }:

# ── Theme ────────────────────────────────────────────────────────────────────
# Tokyo Night — the canonical LazyVim default colourscheme.
# Confirmed options: vim.viAlias, vim.vimAlias, vim.theme.*
# Styles: night | storm | moon | day
{
  programs.nvf = {
    enable = true;

    settings.vim = {
      viAlias  = true;
      vimAlias = true;

      theme = {
        enable      = true;
        name        = "tokyonight";
        style       = "night"; # night | storm | moon | day
        transparent = false;
      };
    };
  };
}
