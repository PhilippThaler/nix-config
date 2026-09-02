{...}: {
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xdg.configFile = {
    "gammastep/config.ini".source = ../dotfiles/gammastep/config.ini;
    "xdg-terminals.list".text = "kitty.desktop\n";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/avif" = "imv.desktop";
      "image/bmp" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/heif" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/jpg" = "imv.desktop";
      "image/jxl" = "imv.desktop";
      "image/png" = "imv.desktop";
      "image/tiff" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/svg+xml" = "org.inkscape.Inkscape.desktop";

      "text/plain" = "nvim.desktop";
      "text/x-c" = "nvim.desktop";
      "text/x-c++" = "nvim.desktop";
      "text/x-tex" = "nvim.desktop";
      "text/x-python" = "nvim.desktop";
      "text/x-shellscript" = "nvim.desktop";
      "text/markdown" = "nvim.desktop";
      "text/x-log" = "nvim.desktop";
      "text/csv" = "nvim.desktop";
      "text/html" = "librewolf.desktop";

      "inode/directory" = "yazi.desktop";

      "x-scheme-handler/mailto" = "neomutt.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/chrome" = "librewolf.desktop";
      "x-scheme-handler/ftp" = "filezilla.desktop";
      "x-scheme-handler/sftp" = "filezilla.desktop";
      "x-scheme-handler/spotify" = "spotify.desktop";
      "x-scheme-handler/nc" = "com.nextcloud.desktopclient.nextcloud.desktop";

      "application/x-extension-htm" = "librewolf.desktop";
      "application/x-extension-html" = "librewolf.desktop";
      "application/x-extension-shtml" = "librewolf.desktop";
      "application/xhtml+xml" = "librewolf.desktop";
      "application/x-extension-xhtml" = "librewolf.desktop";
      "application/x-extension-xht" = "librewolf.desktop";

      "application/zip" = "xarchiver.desktop";
      "application/x-tar" = "xarchiver.desktop";
      "application/gzip" = "xarchiver.desktop";
      "application/x-bzip2" = "xarchiver.desktop";
      "application/x-xz" = "xarchiver.desktop";
      "application/x-7z-compressed" = "xarchiver.desktop";
      "application/x-compressed-tar" = "xarchiver.desktop";
      "application/vnd.rar" = "xarchiver.desktop";
      "application/x-archive" = "xarchiver.desktop";

      "application/vnd.oasis.opendocument.text" = "writer.desktop";
      "application/msword" = "writer.desktop";
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "writer.desktop";
      "application/rtf" = "writer.desktop";
      "application/vnd.oasis.opendocument.spreadsheet" = "calc.desktop";
      "application/vnd.ms-excel" = "calc.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "calc.desktop";
      "application/vnd.oasis.opendocument.presentation" = "impress.desktop";
      "application/vnd.ms-powerpoint" = "impress.desktop";
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "impress.desktop";

      "application/json" = "nvim.desktop";
      "application/x-yaml" = "nvim.desktop";
      "application/yaml" = "nvim.desktop";
      "application/toml" = "nvim.desktop";
      "application/xml" = "nvim.desktop";

      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
      "application/epub+zip" = "org.pwmt.zathura-pdf-mupdf.desktop";
      "application/x-mobipocket-ebook" = "org.pwmt.zathura-pdf-mupdf.desktop";

      "video/mp4" = "mpv.desktop";
      "video/mkv" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/avi" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";

      "audio/flac" = "mpv.desktop";
      "audio/mpeg" = "mpv.desktop";
      "audio/ogg" = "mpv.desktop";
      "audio/opus" = "mpv.desktop";
      "audio/wav" = "mpv.desktop";
      "audio/m4a" = "mpv.desktop";
    };
  };
}
