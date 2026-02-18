{ ... }:

# ── UI / Visual chrome ───────────────────────────────────────────────────────
# Confirmed options from https://nvf.notashelf.dev/options.html:
#   vim.statusline.lualine.*  — confirmed in release notes
#   vim.tabline.nvimBufferline.enable
#   vim.telescope.enable
#   vim.filetree.nvimTree.*
#   vim.dashboard.alpha.enable
{
  programs.nvf.settings.vim = {

    # ── Statusline (lualine) ───────────────────────────────────────────────
    statusline.lualine = {
      enable = true;
      theme  = "tokyonight";
    };

    # ── Tabline / bufferline ───────────────────────────────────────────────
    tabline.nvimBufferline.enable = true;

    # ── Fuzzy finder (telescope) ───────────────────────────────────────────
    telescope.enable = true;

    # ── File tree (nvim-tree) ──────────────────────────────────────────────
    filetree.nvimTree = {
      enable = true;
      setupOpts = {
        view.width           = 30;
        renderer.group_empty = true;
        filters.dotfiles     = false;
      };
    };

    # ── Dashboard (alpha-nvim) ─────────────────────────────────────────────
    dashboard.alpha.enable = true;
  };
}
