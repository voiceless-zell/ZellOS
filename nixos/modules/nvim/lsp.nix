{ ... }:

# ── LSP & Formatting ─────────────────────────────────────────────────────────
# Confirmed options from https://nvf.notashelf.dev/options.html:
#   vim.lsp.enable, vim.lsp.formatOnSave, vim.diagnostics.enable
# Language servers come from nixpkgs via languages.nix — no Mason needed.
{
  programs.nvf.settings.vim = {
    lsp = {
      enable       = true;
      formatOnSave = true;
    };

    # vim.diagnostics.enable is confirmed in the options reference
    diagnostics.enable = true;
  };
}
