# nvim (kickstart.nvim) — declarative placement of the config repo.
#
# ~/.config/nvim is a symlink to the live git checkout at
# ~/Projects/kickstart.nvim; edits apply instantly, lazy.nvim manages
# plugins (versions pinned via lazy-lock.json in that repo).
#
# External deps are declared elsewhere in this flake:
#   neovim, ripgrep, fd, tree-sitter, gcc, gnumake, unzip, wl-clipboard → home.nix
#   git, nerd-fonts                                              → configuration.nix
{ config, ... }:
{
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/home/philipp/Projects/kickstart.nvim";
}
