#!/usr/bin/env bash
# =============================================================================
# ZellOS Installer
# Bootstraps a new NixOS machine from this flake.
# Run from the NixOS live ISO as root:
#   bash scripts/install.sh
# =============================================================================

set -euo pipefail

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}  --> ${NC}$*"; }
success() { echo -e "${GREEN}  ✓   ${NC}$*"; }
warn()    { echo -e "${YELLOW}  !   ${NC}$*"; }
error()   { echo -e "${RED}  ✗   ${NC}$*"; exit 1; }
header()  { echo -e "\n${BOLD}${CYAN}══ $* ══${NC}\n"; }
ask()     { echo -e "${BOLD}${YELLOW}  ?   ${NC}$*"; }

# ── Root check ────────────────────────────────────────────────────────────────
[[ $EUID -ne 0 ]] && error "This script must be run as root."

# ── Clone or locate repo ──────────────────────────────────────────────────────
REPO_URL="https://github.com/voiceless-zell/ZellOS"
REPO_DIR="/tmp/ZellOS"

if [[ -d "$REPO_DIR/.git" ]]; then
  info "Repo found at $REPO_DIR — pulling latest..."
  git -C "$REPO_DIR" pull
else
  info "Cloning ZellOS to $REPO_DIR..."
  git clone "$REPO_URL" "$REPO_DIR"
fi

SCRIPT_DIR="$REPO_DIR/scripts"
FLAKE_ROOT="$REPO_DIR"

# =============================================================================
# STEP 1 — Gather information
# =============================================================================
header "ZellOS Installer — Configuration"

# ── Username ──────────────────────────────────────────────────────────────────
ask "Username for the primary user [default: zell]:"
read -r USERNAME
USERNAME="${USERNAME:-zell}"

if [[ "$USERNAME" == "zell" ]]; then
  info "Using existing zell home-manager profile."
  HM_USER="zell"
else
  info "New user '$USERNAME' — a minimal home-manager profile will be created."
  HM_USER="$USERNAME"
fi

# ── Hostname ──────────────────────────────────────────────────────────────────
ask "Hostname for this machine:"
read -r HOSTNAME
[[ -z "$HOSTNAME" ]] && error "Hostname cannot be empty."

# ── Machine type ──────────────────────────────────────────────────────────────
echo ""
ask "Machine type:"
echo "  1) VM (VirtualBox / QEMU / VMware)"
echo "  2) AMD CPU (bare metal)"
echo "  3) Intel CPU (bare metal)"
read -r MACHINE_TYPE_INPUT
case "$MACHINE_TYPE_INPUT" in
  1) MACHINE_TYPE="vm"    ;;
  2) MACHINE_TYPE="amd"   ;;
  3) MACHINE_TYPE="intel" ;;
  *) error "Invalid selection." ;;
esac

# ── Form factor (skip for VMs) ────────────────────────────────────────────────
FORM_FACTOR="desktop"
if [[ "$MACHINE_TYPE" != "vm" ]]; then
  echo ""
  ask "Form factor:"
  echo "  1) Desktop"
  echo "  2) Laptop (enables wifi & power management)"
  read -r FORM_INPUT
  case "$FORM_INPUT" in
    1) FORM_FACTOR="desktop" ;;
    2) FORM_FACTOR="laptop"  ;;
    *) error "Invalid selection." ;;
  esac
fi

# ── GPU ───────────────────────────────────────────────────────────────────────
echo ""
ask "GPU configuration:"
echo "  1) None / VM (no discrete GPU)"
echo "  2) AMD (amdgpu — open source)"
echo "  3) Intel integrated graphics"
echo "  4) NVIDIA (proprietary drivers)"
read -r GPU_INPUT
case "$GPU_INPUT" in
  1) GPU="none"   ;;
  2) GPU="amd"    ;;
  3) GPU="intel"  ;;
  4) GPU="nvidia" ;;
  *) error "Invalid selection." ;;
esac

# ── Install disk ──────────────────────────────────────────────────────────────
echo ""
info "Available disks:"
lsblk -dpno NAME,SIZE,MODEL | grep -v "loop\|sr"
echo ""
ask "Target disk for installation (e.g. /dev/sda or /dev/nvme0n1):"
read -r DISK
[[ ! -b "$DISK" ]] && error "Disk '$DISK' not found."

# ── Swap size ─────────────────────────────────────────────────────────────────
ask "Swap size in GB [default: 8]:"
read -r SWAP_SIZE
SWAP_SIZE="${SWAP_SIZE:-8}"

# ── User password ─────────────────────────────────────────────────────────────
ask "Password for user '$USERNAME':"
read -rs USER_PASSWORD
echo ""
ask "Confirm password:"
read -rs USER_PASSWORD_CONFIRM
echo ""
[[ "$USER_PASSWORD" != "$USER_PASSWORD_CONFIRM" ]] && error "Passwords do not match."

# ── Confirmation ──────────────────────────────────────────────────────────────
echo ""
header "Configuration Summary"
echo -e "  Username    : ${BOLD}$USERNAME${NC}"
echo -e "  Hostname    : ${BOLD}$HOSTNAME${NC}"
echo -e "  Machine     : ${BOLD}$MACHINE_TYPE${NC}"
echo -e "  Form factor : ${BOLD}$FORM_FACTOR${NC}"
echo -e "  GPU         : ${BOLD}$GPU${NC}"
echo -e "  Disk        : ${BOLD}$DISK${NC}"
echo -e "  Swap        : ${BOLD}${SWAP_SIZE}GB${NC}"
echo -e "  Password    : ${BOLD}[set]${NC}"
echo ""
warn "ALL DATA ON $DISK WILL BE DESTROYED."
ask "Continue? [y/N]:"
read -r CONFIRM
[[ "${CONFIRM,,}" != "y" ]] && error "Aborted."

# =============================================================================
# STEP 2 — Partition and format
# =============================================================================
header "Partitioning $DISK"

# Wipe existing partition table
wipefs -af "$DISK"
sgdisk -Z "$DISK"

# Create partitions:
#   1 — EFI  (512MB)
#   2 — swap (user-specified GB)
#   3 — root (remainder)
sgdisk -n 1:0:+512M  -t 1:ef00 -c 1:boot  "$DISK"
sgdisk -n 2:0:+"${SWAP_SIZE}G" -t 2:8200 -c 2:swap  "$DISK"
sgdisk -n 3:0:0      -t 3:8300 -c 3:nixos "$DISK"

# Re-read partition table
partprobe "$DISK"
sleep 2

# Determine partition suffix (nvme uses p1/p2/p3, sda uses 1/2/3)
if [[ "$DISK" == *"nvme"* ]] || [[ "$DISK" == *"mmcblk"* ]]; then
  PART_PREFIX="${DISK}p"
else
  PART_PREFIX="${DISK}"
fi

PART_BOOT="${PART_PREFIX}1"
PART_SWAP="${PART_PREFIX}2"
PART_ROOT="${PART_PREFIX}3"

info "Formatting EFI partition..."
mkfs.fat -F 32 -n boot "$PART_BOOT"

info "Formatting swap..."
mkswap -L swap "$PART_SWAP"

info "Formatting root (ext4)..."
mkfs.ext4 -L nixos "$PART_ROOT"

success "Partitioning complete."

# =============================================================================
# STEP 3 — Mount
# =============================================================================
header "Mounting Filesystems"

mount "$PART_ROOT" /mnt
mkdir -p /mnt/boot
mount "$PART_BOOT" /mnt/boot
swapon "$PART_SWAP"

success "Filesystems mounted."

# =============================================================================
# STEP 4 — Generate hardware config
# =============================================================================
header "Generating Hardware Configuration"

nixos-generate-config --root /mnt
# We'll use the generated hardware-configuration.nix as our hardware.nix
GENERATED_HW="/mnt/etc/nixos/hardware-configuration.nix"
[[ ! -f "$GENERATED_HW" ]] && error "nixos-generate-config did not produce hardware-configuration.nix"

success "Hardware config generated."

# =============================================================================
# STEP 5 — Build NixOS host config from templates
# =============================================================================
header "Creating Host Configuration"

HOST_DIR="$FLAKE_ROOT/nixos/hosts/$HOSTNAME"
mkdir -p "$HOST_DIR"

# ── Build CPU microcode snippet ───────────────────────────────────────────────
case "$MACHINE_TYPE" in
  amd)
    CPU_MICROCODE="hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;"
    CPU_KMOD="amd"
    ;;
  intel)
    CPU_MICROCODE="hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;"
    CPU_KMOD="intel"
    ;;
  vm)
    CPU_MICROCODE="# No microcode update needed for VMs."
    CPU_KMOD="intel" # qemu default; harmless on amd-based hosts
    ;;
esac

# ── Build GPU snippet ─────────────────────────────────────────────────────────
case "$GPU" in
  amd)
    GPU_CONFIG=$(cat <<'NIXEOF'
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
NIXEOF
)
    ;;
  intel)
    GPU_CONFIG=$(cat <<'NIXEOF'
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver intel-ocl ];
  };
NIXEOF
)
    ;;
  nvidia)
    GPU_CONFIG=$(cat <<'NIXEOF'
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
NIXEOF
)
    ;;
  none)
    GPU_CONFIG="  # No discrete GPU configured."
    ;;
esac

# ── Build wifi snippet ────────────────────────────────────────────────────────
if [[ "$FORM_FACTOR" == "laptop" ]]; then
  WIFI_CONFIG=$(cat <<'NIXEOF'
  # ── Wifi (laptop) ─────────────────────────────────────────────────────────
  # NetworkManager handles connections — use `nmtui` on first boot to connect.
  # iwd is used as the wifi backend for better driver support and performance.
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = false; # NM owns this
  };
  # Power management
  services.tlp.enable = true;
  services.upower.enable = true;
  powerManagement.enable = true;
NIXEOF
)
  NM_CONFIG="  # NetworkManager configured in wifi block below."
  EXTRA_GROUPS="video"
  EXTRA_PACKAGES="networkmanager  # provides nmtui — use on first boot to connect to wifi"
else
  WIFI_CONFIG="  # Desktop — no wifi-specific config needed."
  NM_CONFIG="  networking.networkmanager.enable = true;"
  EXTRA_GROUPS=""
  EXTRA_PACKAGES=""
fi

# ── Build VM snippet ──────────────────────────────────────────────────────────
if [[ "$MACHINE_TYPE" == "vm" ]]; then
  VM_CONFIG=$(cat <<'NIXEOF'
  # VM guest additions
  virtualisation.virtualbox.guest.enable = true;  # comment out if not VirtualBox
  # virtualisation.vmware.guest.enable = true;    # uncomment for VMware
  # services.qemuGuest.enable = true;             # uncomment for QEMU/KVM
NIXEOF
)
else
  VM_CONFIG="  # Bare metal — no VM guest config needed."
fi

# ── Write default.nix directly ───────────────────────────────────────────────
cat > "$HOST_DIR/default.nix" <<NIXEOF
{ inputs, hostname, pkgs, lib, config, ... }:

{
  imports = [
    ./hardware.nix
  ];

  # ── Boot ───────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── CPU microcode ──────────────────────────────────────────────────────────
  $CPU_MICROCODE

  # ── GPU ────────────────────────────────────────────────────────────────────
$GPU_CONFIG

  # ── Networking ─────────────────────────────────────────────────────────────
  networking.hostName = hostname;
$NM_CONFIG

$WIFI_CONFIG

  # ── SSH ────────────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # ── Locale & time ──────────────────────────────────────────────────────────
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── System ─────────────────────────────────────────────────────────────────
  system.stateVersion = "25.05";

  # ── Nix settings ───────────────────────────────────────────────────────────
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # ── Users ──────────────────────────────────────────────────────────────────
  users.users.$USERNAME = {
    isNormalUser = true;
    description = "$USERNAME";
    extraGroups = [ "wheel" "networkmanager" $( [[ -n "$EXTRA_GROUPS" ]] && echo "\"$EXTRA_GROUPS\"" ) ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };

  security.sudo.extraRules = [
    {
      users = [ "$USERNAME" ];
      commands = [
        { command = "ALL"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

  # ── Home Manager ───────────────────────────────────────────────────────────
  home-manager.users.$USERNAME = import ../../../home-manager/users/$USERNAME;

  # ── Global packages ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
    $( [[ -n "$EXTRA_PACKAGES" ]] && echo "$EXTRA_PACKAGES" )
  ];
}
NIXEOF

# ── Write hardware.nix from nixos-generate-config output ─────────────────────
cp "$GENERATED_HW" "$HOST_DIR/hardware.nix"

# Patch in KVM module and VM config using awk (safe for multi-line)
awk -v kmod="$CPU_KMOD" '{ gsub(/__CPU_KMOD__/, kmod); print }' \
  "$HOST_DIR/hardware.nix" > "$HOST_DIR/hardware.nix.tmp" \
  && mv "$HOST_DIR/hardware.nix.tmp" "$HOST_DIR/hardware.nix"

success "Host config created at nixos/hosts/$HOSTNAME/"

# Stage new files so nix flake can see them
git -C "$FLAKE_ROOT" add nixos/hosts/"$HOSTNAME"

# =============================================================================
# STEP 6 — Create home-manager user profile if new user
# =============================================================================
if [[ "$HM_USER" != "zell" ]]; then
  header "Creating Home Manager Profile for $HM_USER"

  HM_USER_DIR="$FLAKE_ROOT/home-manager/users/$HM_USER"
  mkdir -p "$HM_USER_DIR"

  cat > "$HM_USER_DIR/default.nix" <<NIXEOF
{
  pkgs,
  lib,
  hostname,
  ...
}: {
  imports = [
    ../../modules
  ];

  home = {
    username = "$HM_USER";
    homeDirectory = "/home/$HM_USER";
    stateVersion = "25.05";
  };

  home.packages = with pkgs; [
    ripgrep
    fd
    bat
    eza
    fzf
    htop
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "eza";
      ll = "eza -lah";
      cat = "bat";
    };
    initExtra = ''
      export NIX_HOST="\${hostname}"
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      user.name  = "$HM_USER";
      user.email = ""; # ← fill in after install
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.home-manager.enable = true;
}
NIXEOF

  success "Home manager profile created at home-manager/users/$HM_USER/"
  git -C "$FLAKE_ROOT" add home-manager/users/"$HM_USER"
fi

# =============================================================================
# STEP 7 — Add host to flake.nix
# =============================================================================
header "Registering Host in flake.nix"

FLAKE_FILE="$FLAKE_ROOT/flake.nix"

# Check if host already exists
if grep -q "\"$HOSTNAME\"" "$FLAKE_FILE"; then
  warn "Host '$HOSTNAME' already exists in flake.nix — skipping."
else
  # Insert new host entry before the closing of nixosConfigurations
  # Matches the last }; in the nixosConfigurations block
  NEW_HOST_ENTRY="        $HOSTNAME = mkHost \"$HOSTNAME\" \"x86_64-linux\" [];"

  # Use awk to insert before the closing of nixosConfigurations
  awk -v entry="$NEW_HOST_ENTRY" '
    /nixosConfigurations = \{/ { found=1 }
    found && /^\s*\};/ && !inserted {
      print entry
      inserted=1
    }
    { print }
  ' "$FLAKE_FILE" > "${FLAKE_FILE}.tmp" && mv "${FLAKE_FILE}.tmp" "$FLAKE_FILE"

  success "Added '$HOSTNAME' to flake.nix."
  git -C "$FLAKE_ROOT" add flake.nix
fi

# =============================================================================
# STEP 8 — Copy flake to target and install
# =============================================================================
header "Installing NixOS"

NIXOS_DIR="/mnt/etc/nixos"
mkdir -p "$NIXOS_DIR"

info "Copying flake to $NIXOS_DIR ..."
cp -r "$FLAKE_ROOT/." "$NIXOS_DIR/"

# Point flake.nix at the new host
info "Running nixos-install..."
nixos-install --flake "$NIXOS_DIR#$HOSTNAME" --no-root-passwd

info "Setting password for $USERNAME..."
nixos-enter --root /mnt -- passwd "$USERNAME" <<EOF
$USER_PASSWORD
$USER_PASSWORD_CONFIRM
EOF

# =============================================================================
# Done
# =============================================================================
header "Installation Complete"

success "NixOS installed successfully as '$HOSTNAME'."

# ── Write post-reboot instructions to /mnt so they appear on first login ──────
MOTD_FILE="/mnt/etc/nixos/POST_INSTALL.md"
cat > "$MOTD_FILE" <<MOTDEOF
════════════════════════════════════════════════════════════
  ZellOS — Post-Install Steps for '$HOSTNAME'
════════════════════════════════════════════════════════════

$(  [[ "$FORM_FACTOR" == "laptop" ]] && cat <<'LAPTOPEOF'
Step 1 — Connect to wifi:

    sudo nmtui

LAPTOPEOF
)
Step 2 — Generate the host age key for sops:

    sudo mkdir -p /etc/sops/age
    nix-shell -p ssh-to-age --run \
      "ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key \
      | sudo tee /etc/sops/age/keys.txt > /dev/null"
    sudo chmod 644 /etc/sops/age/keys.txt

Step 3 — Get the host public age key (send this to your dev machine):

    nix-shell -p ssh-to-age --run \
      "ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub"

Step 4 — On your dev machine, add the key to .sops.yaml then re-encrypt:

    sops updatekeys secrets/shared.yaml
    git add .sops.yaml secrets/shared.yaml
    git commit -m "feat: add host $HOSTNAME"

Step 5 — Back on this machine, pull and rebuild to apply sops:

    cd /etc/nixos
    git pull
    sudo nixos-rebuild switch --flake .#$HOSTNAME

════════════════════════════════════════════════════════════
  Run: cat /etc/nixos/POST_INSTALL.md to see this again
════════════════════════════════════════════════════════════
MOTDEOF

# Display the instructions before rebooting
cat "$MOTD_FILE"

info "Rebooting in 10 seconds — press Ctrl+C to cancel..."
sleep 10
reboot
