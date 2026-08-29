{...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      server = {
        hostname = "10.69.20.50";
        user = "philipp";
        serverAliveInterval = 30;
        serverAliveCountMax = 3;
      };
      raspi = {
        hostname = "10.69.20.40";
        user = "philipp";
        serverAliveInterval = 30;
        serverAliveCountMax = 3;
      };
    };
  };
}
