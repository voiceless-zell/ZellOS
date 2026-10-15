# NixOS Flake

Multi-host NixOS configuration with WSL and Home Manager support.

## Structure

```
.
├── flake.nix                        # Inputs, outputs, host registration
├── scripts/
│   └── install.sh                   # Interactive installer for new machines
├── nixos/
│   ├── hosts/
│   │   ├── wsl/
│   │   │   ├── default.nix          # WSL NixOS config (hostname: "wsl")
│   │   │   └── hardware.nix         # WSL boot/hardware configuration
│   │   └── template/
│   │       ├── default.nix          # Template for new hosts (filled by install.sh)
│   │       └── hardware.nix         # Hardware template with disk labels
│   └── modules/
│       ├── default.nix              # Shared NixOS modules
│       └── nvim/                    # NVF Neovim config
└── home-manager/
    ├── users/
    │   └── zell/
    │       └── default.nix          # Home Manager config for zell
    └── modules/
        ├── default.nix              # Shared Home Manager modules
        ├── zsh.nix                  # Zsh configuration
        └── starship.nix              # Cross-shell prompt
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
nix-shell -p curl git --run "bash <(curl -L https://raw.githubusercontent.com/voiceless-zell/ZellOS/main/scripts/install.sh)"
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

### Step 3 — Rebuild the new machine

After the first boot, pull the configuration and rebuild using the registered
host name:

```bash
cd ~/ZellOS
git pull
sudo nixos-rebuild switch --flake .#<hostname>
```

## Adding a new user

1. Create `home-manager/users/<username>/default.nix`.
2. Wire it into the relevant host config:
   ```nix
   home-manager.users.<username> = import ../../../home-manager/users/<username>;
   ```

## Applying the config (WSL)

```bash
sudo nixos-rebuild switch --flake ~/ZellOS#wsl
```

## Updating inputs

```bash
nix flake update           # update all inputs
nix flake update nixpkgs   # update only nixpkgs
```
