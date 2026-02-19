# NixOS Flake

Multi-host NixOS configuration with WSL and Home Manager support.

## Structure

```
.
├── flake.nix                        # Inputs, outputs, host registration
├── .sops.yaml                       # sops key policy (age keys + creation rules)
├── scripts/
│   └── install.sh                   # Interactive installer for new machines
├── secrets/
│   ├── README.md                    # How to create/edit secrets
│   └── shared.yaml                  # Encrypted secrets (safe to commit)
├── nixos/
│   ├── hosts/
│   │   ├── wsl/
│   │   │   ├── default.nix          # WSL NixOS config (hostname: "wsl")
│   │   │   └── hardware.nix         # WSL boot/hardware stubs
│   │   └── template/
│   │       ├── default.nix          # Template for new hosts (filled by install.sh)
│   │       └── hardware.nix         # Hardware template with disk labels
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
sudo chmod 644 /etc/sops/age/keys.txt
# Get the public key for .sops.yaml:
nix-shell -p ssh-to-age --run "ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub"
# → paste into .sops.yaml as &host_wsl (or &host_<n>)

# 3. Create the encrypted secrets file (once .sops.yaml has your personal key)
sops secrets/shared.yaml
```

## Adding to a New Machine

The install script handles everything end-to-end: partitioning, formatting,
hardware detection, host config generation, flake registration, and installation.

### Prerequisites

- Boot the target machine from a NixOS live ISO
- Have this repo cloned or available on the live ISO (USB or network)
- Know which disk to install to (`lsblk` to check)

### Step 1 — Run the installer

From the live ISO terminal, paste this single command as root:

```bash
nix-shell -p curl git --run "bash <(curl -L https://raw.githubusercontent.com/voicless-zell/ZellOS/main/scripts/install.sh)"
```

This pulls and runs the script directly — no manual cloning needed. The script
clones the repo to `/tmp/ZellOS` automatically (or pulls if it already exists).

The script will ask you for:

- **Username** — enter `zell` to use the existing profile, or a new name to create a fresh minimal profile
- **Hostname** — the machine's hostname (e.g. `desktop`, `laptop`)
- **Machine type** — VM, AMD bare metal, or Intel bare metal
- **Form factor** — desktop or laptop (laptop enables wifi via NetworkManager + iwd backend, power management via TLP, and includes `nmtui` for connecting to wifi on first boot)
- **GPU** — none/VM, AMD (amdgpu), Intel integrated, or NVIDIA (proprietary)
- **Target disk** — e.g. `/dev/sda` or `/dev/nvme0n1`
- **Swap size** — in GB (default: 8)

The script then:

1. Partitions the disk (512MB EFI + swap + root, all labelled)
2. Formats and mounts the filesystems
3. Runs `nixos-generate-config` for real hardware detection
4. Creates `nixos/hosts/<hostname>/` from the templates
5. Creates a home-manager profile if the user is not `zell`
6. Registers the new host in `flake.nix`
7. Copies the flake to `/mnt/etc/nixos/` and runs `nixos-install`

### Step 2 — First boot: connect to wifi (laptop only)

If this is a laptop, connect to wifi before anything else using `nmtui`:

```bash
sudo nmtui
```

Select **Activate a connection**, choose your network, enter the password, and
you're online. Then proceed with the steps below.

### Step 3 — First boot: generate the host age key

After rebooting into the new system, set up the sops decryption key:

```bash
sudo mkdir -p /etc/sops/age
nix-shell -p ssh-to-age --run \
  "ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key \
  | sudo tee /etc/sops/age/keys.txt > /dev/null"
sudo chmod 644 /etc/sops/age/keys.txt
```

Get the host's public age key to add to `.sops.yaml`:

```bash
nix-shell -p ssh-to-age --run \
  "ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub"
```

### Step 4 — Add the host key to .sops.yaml (from your dev machine)

In `.sops.yaml`, add the new host key under `keys` and include it in the
`creation_rules` group:

```yaml
keys:
  - &user_zell age1...
  - &host_wsl  age1...
  - &host_<hostname> age1...   # ← add this

creation_rules:
  - path_regex: secrets/shared\.yaml$
    key_groups:
      - age:
          - *user_zell
          - *host_wsl
          - *host_<hostname>   # ← and this
```

Then re-encrypt the secrets file so the new host can decrypt it:

```bash
sops updatekeys secrets/shared.yaml
git add .sops.yaml secrets/shared.yaml
git commit -m "feat: add host <hostname>"
```

### Step 5 — Rebuild on the new machine

Pull the updated flake and rebuild:

```bash
cd /etc/nixos
git pull
sudo nixos-rebuild switch --flake .#<hostname>
```

Your secrets will now decrypt correctly and all shared config (Neovim, sops,
home-manager) will be active.

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
