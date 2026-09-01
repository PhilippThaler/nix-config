{...}: {
  programs.yazi = {
    enable = true;
    keymap = {
      mgr.prepend_keymap = [
        {
          run = "hidden toggle";
          on = "<Backspace>";
          desc = "Toggle the visibility of hidden files";
        }
        {
          run = "shell 'aunpack %s'";
          on = ["e" "x"];
          desc = "Extract archive to a folder (atool)";
        }
      ];
    };
  };
}
