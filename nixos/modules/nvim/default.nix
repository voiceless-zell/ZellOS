{ ... }:

{
  imports = [
    ./theme.nix       # Tokyo Night colourscheme
    ./ui.nix          # Lualine, bufferline, Telescope, Neo-tree, dashboard
    ./editor.nix      # Options, cmp, snippets, autopairs, comments, which-key
    ./lsp.nix         # LSP, format-on-save, diagnostics
    ./keys.nix        # All <leader> keymaps
    ./git.nix         # Gitsigns
    ./languages.nix   # Treesitter + LSP + formatters (12 languages)
  ];
}
