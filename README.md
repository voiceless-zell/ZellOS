# NixOS Flake

Multi-host NixOS configuration with WSL and Home Manager support.

## Structure

```
.
├── flake.nix                        # Inputs, outputs, host registration
├── nixos/
│   ├── hosts/
│   │   └── wsl/
│   │       ├── default.nix          # WSL NixOS config (hostname: "wsl")
│   │       └── hardware.nix         # WSL boot/hardware stubs
│   └── modules/
│       └── default.nix              # Shared NixOS modules
└── home-manager/
    ├── users/
    │   └── zell/
    │       └── default.nix          # Home Manager config for zell
    └── modules/
        └── default.nix              # Shared Home Manager modules
```

## Adding a new host

1. Create `nixos/hosts/<hostname>/default.nix` (and optionally `hardware.nix`).
2. Register it in `flake.nix` inside `nixosConfigurations`:
   ```nix
   mynewhost = mkHost "mynewhost" "x86_64-linux" [];
   ```
3. The machine's hostname must match (set via `networking.hostName`).

## Adding a new user

1. Create `home-manager/users/<username>/default.nix`.
2. Wire it into the relevant host config:
   ```nix
   home-manager.users.<username> = import ../../../home-manager/users/<username>;
   ```

## Applying the config (WSL)

```bash
# Apply the full NixOS + Home Manager config
sudo nixos-rebuild switch --flake /path/to/flake#wsl
```

## Updating inputs

```bash
nix flake update           # update all inputs
nix flake update nixpkgs   # update only nixpkgs
```
