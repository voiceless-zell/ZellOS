{ ... }:

# ── Editor behaviour ─────────────────────────────────────────────────────────
# Confirmed options from https://nvf.notashelf.dev/options.html
# Only options explicitly listed in the options reference are used.
{
  programs.nvf.settings.vim = {

    # ── Core options ───────────────────────────────────────────────────────
    # vim.options.* — only confirmed sub-keys from the options page:
    #   tabstop, shiftwidth, signcolumn, splitbelow, splitright,
    #   termguicolors, wrap, autoindent, cmdheight, mouse, updatetime
    options = {
      tabstop      = 2;
      shiftwidth   = 2;
      signcolumn   = "yes";
      splitbelow   = true;
      splitright   = true;
      termguicolors = true;
      wrap         = false;
      autoindent   = true;
      cmdheight    = 1;
      updatetime   = 300;
    };

    # ── Globals ────────────────────────────────────────────────────────────
    # vim.globals.mapleader, vim.globals.maplocalleader confirmed
    globals = {
      mapleader      = " ";
      maplocalleader = " ";
    };

    # ── Line numbers ───────────────────────────────────────────────────────
    # vim.lineNumberMode confirmed — "relNumber" = relative + absolute hybrid
    lineNumberMode = "relNumber";

    # ── Search ─────────────────────────────────────────────────────────────
    # vim.hideSearchHighlight, vim.searchCase confirmed
    hideSearchHighlight = false;
    searchCase          = "smart";

    # ── Prevent swap/backup junk files ────────────────────────────────────
    # vim.preventJunkFiles confirmed
    preventJunkFiles = true;

    # ── Undo file ──────────────────────────────────────────────────────────
    # vim.undoFile.enable confirmed
    undoFile.enable = true;

    # ── Syntax / Lua loader ────────────────────────────────────────────────
    # vim.syntaxHighlighting, vim.enableLuaLoader confirmed
    syntaxHighlighting = true;
    enableLuaLoader    = true;

    # ── Clipboard ──────────────────────────────────────────────────────────
    # vim.clipboard.enable + vim.clipboard.registers confirmed
    clipboard = {
      enable    = true;
      registers = "unnamedplus";
    };

    # ── Autocomplete (nvim-cmp) ────────────────────────────────────────────
    # vim.autocomplete.nvim-cmp.enable confirmed
    autocomplete.nvim-cmp.enable = true;

    # ── Snippets (luasnip) ─────────────────────────────────────────────────
    # vim.snippets.luasnip.enable confirmed in release notes
    snippets.luasnip.enable = true;

    # ── Autopairs ─────────────────────────────────────────────────────────
    # vim.autopairs.nvim-autopairs.enable confirmed
    autopairs.nvim-autopairs.enable = true;

    # ── Comments ──────────────────────────────────────────────────────────
    # vim.comments.comment-nvim.enable confirmed
    comments.comment-nvim.enable = true;

    # ── Which-key ─────────────────────────────────────────────────────────
    # vim.binds.whichKey.enable confirmed
    binds.whichKey.enable = true;

    # ── Spellcheck (off by default, easy to flip on) ───────────────────────
    # vim.spellcheck.enable confirmed
    spellcheck.enable = false;
  };
}
