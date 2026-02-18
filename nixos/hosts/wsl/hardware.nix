{ lib, ... }:

{
  # WSL runs inside the Windows kernel — no bootloader or physical hardware
  # configuration is needed. NixOS-WSL handles the integration layer.

  # Disable systemd-related options that don't apply in WSL
  boot.isContainer = lib.mkDefault true;
}
