{ ... }:

# ── Avante — AI coding assistant ──────────────────────────────────────────────
# Provider: Google Gemini (free tier, no local inference required)
#
# Setup:
#   export GEMINI_API_KEY="your-key-here"
#   Get a free key at https://aistudio.google.com/apikey
#
# Future hosts that run a local model can override provider / model here,
# or add their own avante block with a different provider (e.g. ollama).
#
# Key bindings (avante defaults):
#   <leader>aa  — open AvanteAsk (chat sidebar)
#   <leader>ae  — AvanteEdit (edit selected range)
#   <leader>ar  — AvanteRefresh
#   <leader>at  — AvanteToggle
{
  programs.nvf.settings.vim.assistant.avante-nvim = {
    enable = true;

    setupOpts = {
      provider = "gemini";

      gemini = {
        model    = "gemini-2.0-flash";
        timeout  = 30000;
        extra_request_body = {
          generationConfig = {
            temperature     = 0.7;
            maxOutputTokens = 8192;
          };
        };
      };

      # Disable inline suggestions by default — they consume quota quickly.
      # Enable per-session with :AvanteToggleSuggestion if desired.
      behaviour = {
        auto_suggestions = false;
      };

      # Sidebar appears on the right, matching standard IDE muscle memory
      windows = {
        position = "right";
        wrap     = true;
        width    = 40;
      };
    };
  };
}
