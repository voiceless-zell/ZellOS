{ ... }:

# ── Language support ──────────────────────────────────────────────────────────
# Confirmed options from https://nvf.notashelf.dev/options.html:
#   vim.languages.enableFormat, enableTreesitter, enableExtraDiagnostics
#   vim.treesitter.enable, vim.treesitter.fold, vim.treesitter.grammars
# Per-language blocks use vim.languages.<lang>.enable which triggers
# LSP, treesitter grammar, and formatter when the global toggles are on.
{
  programs.nvf.settings.vim = {

    # ── Global language toggles ────────────────────────────────────────────
    languages = {
      enableFormat           = true;
      enableTreesitter       = true;
      enableExtraDiagnostics = true;

      # Nix
      nix.enable    = true;

      # Lua
      lua.enable    = true;

      # Bash / Shell
      bash.enable   = true;

      # Python
      python.enable = true;

      # TypeScript / JavaScript
      ts.enable     = true;

      # CSS
      css.enable    = true;

      # HTML
      html.enable   = true;

      # JSON
      json.enable   = true;

      # YAML
      yaml.enable   = true;

      # Markdown
      markdown.enable = true;

      # Go
      go.enable     = true;

      # Rust
      rust.enable   = true;
    };

    # ── Treesitter ─────────────────────────────────────────────────────────
    treesitter = {
      enable               = true;
      fold                 = true;
      addDefaultGrammars   = true;
    };
  };
}
