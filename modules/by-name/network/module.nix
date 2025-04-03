{ ... }:
{
  config = {
    services.openssh.enable = true;

    networking = {
      nameservers = [ "1.1.1.1" ];
      useDHCP = true;
      dhcpcd.persistent = true;
    };
  };
}
