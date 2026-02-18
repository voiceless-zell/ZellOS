# NixOS Flake

Multi-host NixOS configuration with WSL and Home Manager support.

## Structure

```
.
├── flake.nix                        # Inputs, outputs, host registration
├── .sops.yaml                       # sops key policy (age keys + creation rules)
├── secrets/
│   ├── README.md                    # How to create/edit secrets
│   └── shared.yaml                  # Encrypted secrets (safe to commit)
├── nixos/
│   ├── hosts/
│   │   └── wsl/
│   │       ├── default.nix          # WSL NixOS config (hostname: "wsl")
│   │       └── hardware.nix         # WSL boot/hardware stubs
│   └── modules/
│       ├── default.nix              # Shared NixOS modules
│       ├── sops.nix                 # System-level secret decryption
│       └── nvim/                    # NVF Neovim config
└── home-manager/
    ├── users/
    │   └── zell/
    │       └── default.nix          # Home Manager config for zell
    └── modules/
        ├── default.nix              # Shared Home Manager modules
        └── sops.nix                 # User-level secret deployment (~/.ssh, env vars)
```

## First-time secrets setup

See `secrets/README.md` for full detail. Quick summary:

```bash
# 1. Derive your personal age key from your user SSH key and store it
mkdir -p ~/.config/sops/age
nix-shell -p ssh-to-age --run \
  "ssh-to-age < ~/.ssh/id_ed25519.pub"
# → paste the output into .sops.yaml as &user_zell

# 2. On each deployed machine, derive the host age key from the SSH host key
sudo mkdir -p /etc/sops/age
nix-shell -p ssh-to-age --run \
  "ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key \
  | sudo tee /etc/sops/age/keys.txt > /dev/null"
sudo chmod 600 /etc/sops/age/keys.txt
# Get the public key for .sops.yaml:
nix-shell -p ssh-to-age --run "ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub"
# → paste into .sops.yaml as &host_wsl (or &host_<name>)

# 3. Create the encrypted secrets file (once .sops.yaml has your personal key)
sops secrets/shared.yaml
```

## Adding a new host

1. Create `nixos/hosts/<hostname>/default.nix` (and optionally `hardware.nix`).
2. Register it in `flake.nix`:
   ```nix
   mynewhost = mkHost "mynewhost" "x86_64-linux" [];
   ```
3. Add the new host's age public key to `.sops.yaml` and re-encrypt:
   ```bash
   sops updatekeys secrets/shared.yaml
   ```
4. The machine's hostname must match (set via `networking.hostName`).

## Adding a new user

1. Create `home-manager/users/<username>/default.nix`.
2. Wire it into the relevant host config:
   ```nix
   home-manager.users.<username> = import ../../../home-manager/users/<username>;
   ```

## Applying the config (WSL)

```bash
sudo nixos-rebuild switch --flake /path/to/flake#wsl
```

## Updating inputs

```bash
nix flake update           # update all inputs
nix flake update nixpkgs   # update only nixpkgs
```
