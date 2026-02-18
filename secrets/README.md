# secrets/

This directory holds sops-encrypted secret files. All files here are safe to
commit to git — they are encrypted and can only be decrypted by the age keys
listed in `../.sops.yaml`.

## Files

| File            | Contents                                    |
|-----------------|---------------------------------------------|
| `shared.yaml`   | Secrets shared across all hosts             |

## Creating / editing secrets

Make sure `sops`, `age`, and `ssh-to-age` are available (they are added to
`environment.systemPackages` by `nixos/modules/sops.nix`).

**First time setup on a new machine:**

```bash
# 1. Generate the machine's age key from its SSH host key
sudo mkdir -p /etc/sops/age
nix-shell -p ssh-to-age --run \
  "ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key \
  | sudo tee /etc/sops/age/keys.txt > /dev/null"
sudo chmod 600 /etc/sops/age/keys.txt

# 2. Get the PUBLIC age key to add to .sops.yaml
nix-shell -p ssh-to-age --run \
  "ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub"
```

**Creating shared.yaml for the first time:**

```bash
# Your personal age key must be in ~/.config/sops/age/keys.txt
# (derived from your user SSH key — see .sops.yaml for the command)
sops secrets/shared.yaml
```

The file should contain:

```yaml
ssh:
    github: |
        -----BEGIN OPENSSH PRIVATE KEY-----
        <paste your GitHub SSH private key here>
        -----END OPENSSH PRIVATE KEY-----
gemini:
    api_key: your-gemini-api-key-here
```

**Editing existing secrets:**

```bash
sops secrets/shared.yaml
```

**Adding a new host (re-encrypting for a new machine):**

```bash
# 1. Add the host's age pubkey to .sops.yaml
# 2. Re-encrypt:
sops updatekeys secrets/shared.yaml
```
