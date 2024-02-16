{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./networking.nix
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/matrix.nix
  ];

  system.stateVersion = "23.11";
  networking = {
    hostName = "kashenblade";
    domain = "zebre.us";
  };

  modules.matrix =
    {
      enable = true;
      baseDomain = "zebre.us";
      certEmail = "lennarteichhorn@googlemail.com";
    };
}
