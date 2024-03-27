{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:zebreus/home-manager?ref=init-secret-service";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-nix-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gnome-online-accounts-config = {
      # url = "/home/lennart/Documents/gnome-online-accounts-config";
      url = "github:zebreus/gnome-online-accounts-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, agenix, simple-nix-mailserver, gnome-online-accounts-config, ... }@attrs:
    let

      overlays = [
        (final: prev: {
          agenix = agenix.packages.${prev.system}.default;
        })
      ];
      pkgs = import nixpkgs {
        inherit overlays;
        system = "x86_64-linux";
      };
      publicKeys = import secrets/public-keys.nix;

      # Add some extra packages to nixpkgs
      overlayNixpkgs = ({ config, pkgs, ... }: {
        nixpkgs.overlays = overlays;
      });

      # Sets config options with information about other machines.
      # Only contains the information that is relevant for all machines.
      informationAboutOtherMachines = {
        imports = [
          modules/machines.nix
        ];
        machines = {
          erms = {
            name = "erms";
            address = 1;
            wireguardPublicKey = publicKeys.erms_wireguard;
            trusted = true;
            # TODO: Automatically add port 25 to publicPorts if managed = true (thats the default for managed)
            publicPorts = [ 25 ];
            sshPublicKey = publicKeys.erms;
            relaxedSpf = true;
          };
          kashenblade = {
            name = "kashenblade";
            address = 2;
            wireguardPublicKey = publicKeys.kashenblade_wireguard;
            staticIp4 = "167.235.154.30";
            staticIp6 = "2a01:4f8:c0c:d91f::1";
            publicPorts = [ 25 ];
            sshPublicKey = publicKeys.kashenblade;
          };
          kappril = {
            name = "kappril";
            address = 3;
            wireguardPublicKey = publicKeys.kappril_wireguard;
            public = true;
            publicPorts = [ 25 ];
            sshPublicKey = publicKeys.kappril;
            relaxedSpf = true;
          };
          # Janeks laptop
          janek = {
            name = "janek";
            address = 4;
            wireguardPublicKey = publicKeys.janek_wireguard;
          };
          # Janeks server
          janek-proxmox = {
            name = "janek-proxmox";
            address = 5;
            wireguardPublicKey = publicKeys.janek-proxmox_wireguard;
          };
          # Janeks backup server
          janek-backup = {
            name = "janek-backup";
            address = 6;
            wireguardPublicKey = publicKeys.janek-backup_wireguard;
            public = true;
          };
          sempriaq = {
            name = "sempriaq";
            address = 7;
            wireguardPublicKey = publicKeys.sempriaq_wireguard;
            sshPublicKey = publicKeys.sempriaq;
            # This machine is allow to contact port 25 on every other machine.
            trustedPorts = [ 25 ];
            publicPorts = [ 25 ];
            public = true;
            # staticIp4 = "192.227.228.220";
          };
          # hetzner-template = {
          #   name = "hetzner-template";
          #   address = 99;
          #   wireguardPublicKey = publicKeys.hetzner-template_wireguard;
          #   publicPorts = [ 25 ];
          #   sshPublicKey = publicKeys.hetzner-template;
          # };
          blanderdash = {
            name = "blanderdash";
            address = 8;
            wireguardPublicKey = publicKeys.blanderdash_wireguard;
            publicPorts = [ 25 ];
            sshPublicKey = publicKeys.blanderdash;
          };
        };
      };
    in
    rec   {
      nixosConfigurations =
        {
          erms = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = attrs;
            modules = [
              overlayNixpkgs
              informationAboutOtherMachines
              agenix.nixosModules.default
              home-manager.nixosModules.home-manager
              gnome-online-accounts-config.nixosModules.default
              ./machines/erms
            ];
          };

          kashenblade = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs = attrs;
            modules = [
              overlayNixpkgs
              informationAboutOtherMachines
              agenix.nixosModules.default
              home-manager.nixosModules.home-manager
              gnome-online-accounts-config.nixosModules.default
              ./machines/kashenblade
            ];
          };

          kappril = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs = attrs;
            modules = [
              overlayNixpkgs
              informationAboutOtherMachines
              home-manager.nixosModules.home-manager
              agenix.nixosModules.default
              gnome-online-accounts-config.nixosModules.default
              ./machines/kappril
            ];
          };

          sempriaq = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = attrs;
            modules = [
              overlayNixpkgs
              informationAboutOtherMachines
              home-manager.nixosModules.home-manager
              agenix.nixosModules.default
              simple-nix-mailserver.nixosModules.default
              gnome-online-accounts-config.nixosModules.default
              ./machines/sempriaq
            ];
          };

          hetzner-template = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              agenix.nixosModules.default
              disko.nixosModules.disko # Remove this after initial setup
              # overlayNixpkgs
              # informationAboutOtherMachines
              # home-manager.nixosModules.home-manager
              # gnome-online-accounts-config.nixosModules.default
              ./machines/hetzner-template
            ];
          };

          blanderdash = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              agenix.nixosModules.default
              overlayNixpkgs
              informationAboutOtherMachines
              home-manager.nixosModules.home-manager
              gnome-online-accounts-config.nixosModules.default
              ./machines/blanderdash
            ];
          };
        };

      # Helper scripts
      gen-host-keys = pkgs.callPackage ./scripts/gen-host-keys.nix { };
      gen-wireguard-keys = pkgs.callPackage ./scripts/gen-wireguard-keys.nix { };
      gen-borg-keys = pkgs.callPackage ./scripts/gen-borg-keys.nix { };
      gen-vpn-mail-secrets = pkgs.callPackage ./scripts/gen-vpn-mail-secrets.nix { };
      gen-mail-dkim-keys = pkgs.callPackage ./scripts/gen-mail-dkim-keys.nix { };
      deploy-hosts = pkgs.callPackage ./scripts/deploy-hosts.nix { };

      # Raspi SD card image
      image.kappril = nixosConfigurations.kappril.config.system.build.sdImage;
    };
}
