{config, ...}: {
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [config.age.secrets.wg_keys.path];
    profiles.wg = {
      connection = {
        id = "wg";
        uuid = "f597fcca-8bf8-43a9-b3ec-1fdea7900ecd";
        type = "wireguard";
        interface-name = "wg";
        autoconnect = "false";
      };
      wireguard = {
        private-key = "$WG_PRIVATE_KEY";
        listen-port = 51820;
        # explicit: the 0.0.0.0/0 peer route must go to its own table + fwmark rules,
        # otherwise the tunnel's own packets to the endpoint are routed back into it
        ip4-auto-default-route = "1";
        ip6-auto-default-route = "0";
      };
      ipv4 = {
        method = "manual";
        address1 = "10.69.50.3/32";
        dns = "10.69.20.40;10.69.20.64;";
        dns-priority = "50";
        # deliberately no gateway=: it conflicts with NM's fwmark default-route handling
      };
      ipv6.method = "ignore";
      "wireguard-peer.XRjxuvnYcJGpnDl8U2nEtu1wQs7hWQ9NEaxi58gGJBY=" = {
        endpoint = "wireguard.thaler.fyi:51820";
        allowed-ips = "0.0.0.0/0;::/0;";
        preshared-key = "$WG_PRESHARED_KEY";
        # without this NM treats the PSK as "not required" (flags=4) and never applies it
        preshared-key-flags = "0";
      };
    };
  };
}
