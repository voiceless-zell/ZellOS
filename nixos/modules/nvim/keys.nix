{ ... }:

# ── Keybindings ───────────────────────────────────────────────────────────────
# vim.keymaps is a confirmed option. which-key is enabled in editor.nix.
# All bindings use <Space> as leader, mirroring LazyVim conventions.
{
  programs.nvf.settings.vim.keymaps = [

    # ── Window navigation ──────────────────────────────────────────────────
    { key = "<C-h>"; mode = "n"; action = "<C-w>h"; desc = "Go to left window"; }
    { key = "<C-j>"; mode = "n"; action = "<C-w>j"; desc = "Go to lower window"; }
    { key = "<C-k>"; mode = "n"; action = "<C-w>k"; desc = "Go to upper window"; }
    { key = "<C-l>"; mode = "n"; action = "<C-w>l"; desc = "Go to right window"; }

    # ── Resize windows ─────────────────────────────────────────────────────
    { key = "<C-Up>";    mode = "n"; action = "<cmd>resize +2<cr>";          desc = "Increase window height"; }
    { key = "<C-Down>";  mode = "n"; action = "<cmd>resize -2<cr>";          desc = "Decrease window height"; }
    { key = "<C-Left>";  mode = "n"; action = "<cmd>vertical resize -2<cr>"; desc = "Decrease window width"; }
    { key = "<C-Right>"; mode = "n"; action = "<cmd>vertical resize +2<cr>"; desc = "Increase window width"; }

    # ── Buffer navigation ──────────────────────────────────────────────────
    { key = "<S-h>"; mode = "n"; action = "<cmd>bprevious<cr>"; desc = "Prev buffer"; }
    { key = "<S-l>"; mode = "n"; action = "<cmd>bnext<cr>";     desc = "Next buffer"; }

    # ── Move lines ─────────────────────────────────────────────────────────
    { key = "<A-j>"; mode = "n"; action = "<cmd>m .+1<cr>==";        desc = "Move line down"; }
    { key = "<A-k>"; mode = "n"; action = "<cmd>m .-2<cr>==";        desc = "Move line up"; }
    { key = "<A-j>"; mode = "i"; action = "<esc><cmd>m .+1<cr>==gi"; desc = "Move line down"; }
    { key = "<A-k>"; mode = "i"; action = "<esc><cmd>m .-2<cr>==gi"; desc = "Move line up"; }
    { key = "<A-j>"; mode = "v"; action = ":m '>+1<cr>gv=gv";        desc = "Move line down"; }
    { key = "<A-k>"; mode = "v"; action = ":m '<-2<cr>gv=gv";        desc = "Move line up"; }

    # ── Clear search highlight ─────────────────────────────────────────────
    { key = "<esc>"; mode = "n"; action = "<cmd>noh<cr><esc>"; desc = "Clear search highlight"; }

    # ── Save / Quit ────────────────────────────────────────────────────────
    { key = "<C-s>";      mode = ["i" "x" "n" "s"]; action = "<cmd>w<cr><esc>"; desc = "Save file"; }
    { key = "<leader>qq"; mode = "n";                action = "<cmd>qa<cr>";     desc = "Quit all"; }

    # ── File tree ──────────────────────────────────────────────────────────
    { key = "<leader>e"; mode = "n"; action = "<cmd>NvimTreeToggle<cr>"; desc = "Toggle file explorer"; }
    { key = "<leader>E"; mode = "n"; action = "<cmd>NvimTreeFocus<cr>";  desc = "Focus file explorer"; }

    # ── Telescope ──────────────────────────────────────────────────────────
    { key = "<leader><space>"; mode = "n"; action = "<cmd>Telescope find_files<cr>";  desc = "Find files"; }
    { key = "<leader>/";       mode = "n"; action = "<cmd>Telescope live_grep<cr>";   desc = "Live grep"; }
    { key = "<leader>ff";      mode = "n"; action = "<cmd>Telescope find_files<cr>";  desc = "Find files"; }
    { key = "<leader>fg";      mode = "n"; action = "<cmd>Telescope live_grep<cr>";   desc = "Live grep"; }
    { key = "<leader>fb";      mode = "n"; action = "<cmd>Telescope buffers<cr>";     desc = "Buffers"; }
    { key = "<leader>fh";      mode = "n"; action = "<cmd>Telescope help_tags<cr>";   desc = "Help tags"; }
    { key = "<leader>fr";      mode = "n"; action = "<cmd>Telescope oldfiles<cr>";    desc = "Recent files"; }

    # ── LSP ────────────────────────────────────────────────────────────────
    { key = "gd"; mode = "n"; action = "<cmd>Telescope lsp_definitions<cr>";      desc = "Go to definition"; }
    { key = "gr"; mode = "n"; action = "<cmd>Telescope lsp_references<cr>";       desc = "References"; }
    { key = "gi"; mode = "n"; action = "<cmd>Telescope lsp_implementations<cr>";  desc = "Go to implementation"; }
    { key = "gt"; mode = "n"; action = "<cmd>Telescope lsp_type_definitions<cr>"; desc = "Go to type definition"; }
    { key = "K";  mode = "n"; action = "<cmd>lua vim.lsp.buf.hover()<cr>";        desc = "Hover docs"; }
    { key = "<leader>ca"; mode = ["n" "v"]; action = "<cmd>lua vim.lsp.buf.code_action()<cr>"; desc = "Code action"; }
    { key = "<leader>cr"; mode = "n"; action = "<cmd>lua vim.lsp.buf.rename()<cr>";             desc = "Rename symbol"; }
    { key = "<leader>cd"; mode = "n"; action = "<cmd>lua vim.diagnostic.open_float()<cr>";       desc = "Line diagnostics"; }
    { key = "[d"; mode = "n"; action = "<cmd>lua vim.diagnostic.goto_prev()<cr>"; desc = "Prev diagnostic"; }
    { key = "]d"; mode = "n"; action = "<cmd>lua vim.diagnostic.goto_next()<cr>"; desc = "Next diagnostic"; }

    # ── Git (gitsigns via vim.git.enable) ─────────────────────────────────
    { key = "<leader>gb"; mode = "n"; action = "<cmd>Gitsigns blame_line<cr>"; desc = "Git blame line"; }
    { key = "<leader>gd"; mode = "n"; action = "<cmd>Gitsigns diffthis<cr>";   desc = "Git diff this"; }
    { key = "]h"; mode = "n"; action = "<cmd>Gitsigns next_hunk<cr>"; desc = "Next git hunk"; }
    { key = "[h"; mode = "n"; action = "<cmd>Gitsigns prev_hunk<cr>"; desc = "Prev git hunk"; }

    # ── Windows ────────────────────────────────────────────────────────────
    { key = "<leader>-";  mode = "n"; action = "<C-W>s"; desc = "Split window below"; }
    { key = "<leader>|";  mode = "n"; action = "<C-W>v"; desc = "Split window right"; }
    { key = "<leader>wd"; mode = "n"; action = "<C-W>c"; desc = "Delete window"; }

    # ── Tabs ───────────────────────────────────────────────────────────────
    { key = "<leader><tab>n"; mode = "n"; action = "<cmd>tabnew<cr>";      desc = "New tab"; }
    { key = "<leader><tab>]"; mode = "n"; action = "<cmd>tabnext<cr>";     desc = "Next tab"; }
    { key = "<leader><tab>["; mode = "n"; action = "<cmd>tabprevious<cr>"; desc = "Previous tab"; }
    { key = "<leader><tab>d"; mode = "n"; action = "<cmd>tabclose<cr>";    desc = "Close tab"; }
  ];
}
