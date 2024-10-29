{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [ "8.8.8.8"
 ];
    defaultGateway = "165.227.128.1";
    defaultGateway6 = {
      address = "";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="165.227.131.240"; prefixLength=20; }
{ address="10.19.0.5"; prefixLength=16; }
        ];
        ipv6.addresses = [
          { address="fe80::58cf:a4ff:fecc:b6a6"; prefixLength=64; }
        ];
        ipv4.routes = [ { address = "165.227.128.1"; prefixLength = 32; } ];
        ipv6.routes = [ { address = ""; prefixLength = 128; } ];
      };
            eth1 = {
        ipv4.addresses = [
          { address="10.114.0.2"; prefixLength=20; }
        ];
        ipv6.addresses = [
          { address="fe80::a85a:12ff:fe24:5d66"; prefixLength=64; }
        ];
        };
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="5a:cf:a4:cc:b6:a6", NAME="eth0"
    ATTR{address}=="aa:5a:12:24:5d:66", NAME="eth1"
  '';
}
