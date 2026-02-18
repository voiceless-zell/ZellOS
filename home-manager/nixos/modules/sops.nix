{ pkgs, ... }:

# ── sops-nix — system-level secret configuration ─────────────────────────────
#
# Decryption key:
#   The machine decrypts secrets using the age key derived from its SSH host key.
#   sops-nix can do this automatically at activation time by reading the host key.
#   The derived age key is written to /etc/sops/age/keys.txt on first boot by
#   running: ssh-to-age -i /etc/ssh/ssh_host_ed25519_key
#
#   For new hosts, add the host's age public key to .sops.yaml (see README) and
#   re-encrypt the secrets file before deploying.
#
# Secrets file:
#   secrets/shared.yaml — encrypted YAML committed to the repo.
#   Each key becomes a file under /run/secrets/ at activation time.
{
  environment.systemPackages = with pkgs; [
    sops   # CLI for editing/encrypting secrets files
    age    # encryption backend
    ssh-to-age  # derive age keys from SSH host keys
  ];

  sops = {
    # The age private key for THIS machine — derived from the SSH host key.
    # On a fresh host, generate it with:
    #   mkdir -p /etc/sops/age
    #   ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key \
    #     > /etc/sops/age/keys.txt
    age.keyFile = "/etc/sops/age/keys.txt";

    # Default secrets file — relative to the flake root.
    # All sops.secrets entries without an explicit `sopsFile` use this.
    defaultSopsFile = ../../secrets/shared.yaml;

    # The GitHub SSH private key: deployed as a system-owned secret so that
    # home-manager can reference its path. The actual symlink into ~/.ssh is
    # handled in home-manager/modules/sops.nix.
    secrets."ssh/github" = {
      # Decoded to /run/secrets/ssh/github at activation time.
      # Permissions: owner = zell, mode = 0600 (required for SSH to accept it).
      owner = "zell";
      mode  = "0600";
    };
  };
}
