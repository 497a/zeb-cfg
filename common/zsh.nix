{ pkgs, ... }:
let
  new-any-nix-shell = pkgs.any-nix-shell.overrideAttrs (old: {
    version = "gitt"; # usually harmless to omit
    src = pkgs.fetchFromGitHub {
      owner = "Zebreus";
      repo = "any-nix-shell";
      rev = "f89bc7241251a5797a4bf5fb525e18b48e5743c4";
      sha256 = "sha256-Hk5rUoqqn+4M903sPwSxf+k3NNq7ZaVC2xdDIsqcGBo=";
    };
  });
in
{
  # Set zsh as the default shell
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      update = "sudo nixos-rebuild switch";
      # cd = "z";
      cat = "bat";
    };
    histSize = 50000;

    ohMyZsh = {
      enable = true;
      plugins = [
        "git"
        #     "thefuck"
        "history-substring-search"
        "web-search"
        "zoxide"
      ];
      theme = "fishy";
    };
  };

  users.defaultUserShell = pkgs.zsh;
  environment.binsh = "${pkgs.zsh}/bin/zsh";


  home-manager.users.lennart = { pkgs, ... }: {
    programs.zsh = {
      enable = true;
      initExtra = ''
        any-nix-shell zsh --info-right | source /dev/stdin
      '';
    };
    home.stateVersion = "22.11";
  };

  environment.systemPackages = with pkgs; [
    new-any-nix-shell
    fzf
    zoxide
    bat
    zsh
    zsh-autosuggestions
  ];
}
