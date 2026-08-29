{config, ...}: {
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/home/philipp/Projects/kickstart.nvim";
}
