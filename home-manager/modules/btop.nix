{...}: {
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "Default";
      truecolor = true;
      terminal_sync = true;
      graph_symbol = "braille";
      rounded_corners = true;
      vim_keys = false;

      shown_boxes = "cpu mem net proc";
      update_ms = 2000;
      presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";

      proc_sorting = "memory";
      proc_colors = true;
      proc_gradient = true;
      proc_mem_bytes = true;
      proc_cpu_graphs = true;

      cpu_invert_lower = true;
      show_uptime = true;
      show_cpu_watts = true;
      check_temp = true;
      show_coretemp = true;
      temp_scale = "celsius";
      show_cpu_freq = true;
      freq_mode = "first";
      clock_format = "%X";

      mem_graphs = true;
      show_swap = true;
      swap_disk = true;

      use_fstab = true;
      show_io_stat = true;

      net_download = 100;
      net_upload = 100;
      net_auto = true;
      net_sync = true;

      show_battery = true;
      show_battery_watts = true;
      log_level = "WARNING";

      # nix owns btop.conf, and btop cannot write to the read-only store path
      save_config_on_exit = false;
    };
  };
}
