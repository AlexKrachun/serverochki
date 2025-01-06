{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./network.nix
    ./wireguard.nix
    ./secrets.nix
    ./nix-settings.nix
    ./constants.nix
  ];

  security.sudo.wheelNeedsPassword = false;

  services.qemuGuest.enable = true;

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  time.timeZone = "Europe/Moscow";

  users.users = {
    alexkarachun = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOeoKxT/YbOkRXysyT3NUWAs0KMwyxUC8ZjyxD/ml5L2 alex@karachun.com"
      ];
    };
    liferooter = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPqqape1/IJC8PK+7lJxwM9N9Oo4SK7HZ7SnCMZjmaTR liferooter@computer"
      ];
    };
  };

  programs.fish.enable = true;
  services.openssh.enable = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}
