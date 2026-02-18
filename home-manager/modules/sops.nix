{ config, ... }:

# ── sops-nix — home-manager user secret deployment ───────────────────────────
#
# The SSH private key is decrypted at the system level (nixos/modules/sops.nix)
# and lands at /run/secrets/ssh/github.  Here we just point the home-manager
# sops module at the same age key so it can manage additional user-scoped
# secrets in the future (e.g. the Gemini API key for Avante).
#
# The GitHub SSH key is wired into ~/.ssh/config via programs.ssh so that SSH
# picks it up automatically — no manual symlinking needed.
{
  # User-level age key — same key as the system, just referenced from the
  # user's perspective.  The file must not be password-protected.
  sops = {
    age.keyFile = "/etc/sops/age/keys.txt";

    # ── Gemini API key for Avante ───────────────────────────────────────────
    # Stored in secrets/shared.yaml under the key "gemini/api_key".
    # Decrypted to /run/user/secrets/gemini/api_key at login time.
    secrets."gemini/api_key" = {
      sopsFile = ../../secrets/shared.yaml;
    };
  };

  # ── GitHub SSH key ──────────────────────────────────────────────────────────
  # The private key lives at /run/secrets/ssh/github (system-decrypted, 0600).
  # We reference it from ~/.ssh/config so SSH uses it automatically for GitHub.
  programs.ssh = {
    enable = true;
    matchBlocks."github.com" = {
      hostname     = "github.com";
      user         = "git";
      identityFile = "/run/secrets/ssh/github";
    };
  };

  # ── Gemini key as a shell environment variable ─────────────────────────────
  # Reads the decrypted file at shell start and exports it as GEMINI_API_KEY
  # so Avante picks it up automatically without hardcoding the value anywhere.
  programs.bash.initExtra = ''
    if [ -f "${config.sops.secrets."gemini/api_key".path}" ]; then
      export GEMINI_API_KEY="$(cat ${config.sops.secrets."gemini/api_key".path})"
    fi
  '';
}
