{
  description = "NixOS configuration with WSL support";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, nvf, sops-nix, ... }@inputs:
    let
      # Helper to build a NixOS system config for a given host
      mkHost = hostname: system: extraModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs hostname; };
          modules = [
            ./nixos/hosts/${hostname}
            ./nixos/modules
            nvf.nixosModules.default          # system-wide nvf — available to all users/root
            sops-nix.nixosModules.sops        # system-level secret decryption
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs hostname; };
              home-manager.sharedModules = [
                sops-nix.homeManagerModules.sops  # user-level secret deployment
              ];
            }
          ] ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        # WSL host — hostname must be set to "wsl" on the machine
        wsl = mkHost "wsl" "x86_64-linux" [
          nixos-wsl.nixosModules.wsl
        ];
      };
    };
}
