{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./webcam.nix
    ./thinkmorse.nix
    ../../modules
  ];

  system.stateVersion = "22.05";
  networking.hostName = "erms";

  services.thinkmorse = {
    enable = true;
    message = "Hello World!";
    devices = [ "tpacpi::lid_logo_dot" ];
    speed = "0.3";
  };

  boot = {
    extraModprobeConfig = ''
      options thinkpad_acpi fan_control=1
    '';
  };

  # Temporary for pentesting course at uni
  networking.hosts = {
    "10.2.17.8" = [
      "friends.connect.usd"
      "connect.usd"
    ];
  };
}
