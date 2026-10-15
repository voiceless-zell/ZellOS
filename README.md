# ZellOS

Multi-host NixOS flake with NixOS-WSL, Home Manager, and NVF support.

## Repository structure

```
.
├── flake.nix
├── flake.lock
├── nixos/
│   ├── hosts/
│   │   ├── wsl/
│   │   │   ├── default.nix
│   │   │   └── hardware.nix
│   │   └── template/
│   │       ├── default.nix
│   │       └── hardware.nix
│   └── modules/
│       ├── default.nix
│       └── nvim/
└── home-manager/
    ├── users/
    │   └── zell/
    │       └── default.nix
    └── modules/
        ├── default.nix
        ├── zsh.nix
        └── starship.nix
```

## Apply the WSL configuration

From the repository directory on the existing NixOS-WSL instance:

```bash
sudo nixos-rebuild switch --flake .#wsl
```

The WSL host configuration uses the `zell` account and keeps
`boot.isContainer = lib.mkDefault true;` in its hardware module.

## Add a host

1. Create `nixos/hosts/<hostname>/default.nix` and
   `nixos/hosts/<hostname>/hardware.nix`.
2. Add a `nixosConfigurations` entry in `flake.nix`, using the shared
   `mkHost` helper and any host-specific modules.
3. Add or select the appropriate Home Manager user profile.
4. Check and apply the configuration:

   ```bash
   nix flake check
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

## Add a Home Manager user

1. Create `home-manager/users/<username>/default.nix`.
2. Import the profile in the host configuration:

   ```nix
   home-manager.users.<username> = import ../../../home-manager/users/<username>;
   ```

## Update flake inputs

```bash
nix flake update           # update all inputs
nix flake update nixpkgs   # update only nixpkgs
```
