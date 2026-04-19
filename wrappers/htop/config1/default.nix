{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
in
mkIf (config.flavour == "config1") {
  extraPackages = [ pkgs.lm_sensors ];

  settings = {
    config_reader_min_version = 3;
    hide_kernel_threads = false;
    hide_userland_threads = false;
    hide_running_in_container = false;
    shadow_other_users = false;
    show_thread_names = false;
    show_program_path = true;
    highlight_base_name = true;
    highlight_deleted_exe = true;
    shadow_distribution_path_prefix = false;
    highlight_megabytes = true;
    highlight_threads = true;
    highlight_changes = false;
    highlight_changes_delay_secs = 5;
    find_comm_in_cmdline = true;
    strip_exe_from_cmdline = true;
    show_merged_command = false;
    header_margin = true;
    screen_tabs = true;
    detailed_cpu_time = false;
    cpu_count_from_one = true;
    show_cpu_usage = true;
    show_cpu_frequency = true;
    show_cpu_temperature = true;
    degree_fahrenheit = false;
    show_cached_memory = true;
    update_process_names = false;
    account_guest_in_cpu_meter = false;
    color_scheme = 6;
    enable_mouse = true;
    delay = 10;
    hide_function_bar = false;
    header_layout = "two_50_50";
    column_meters_0 = "DateTime System Uptime Memory Swap Battery DiskIO NetworkIO";
    column_meter_modes_0 = "2 2 2 1 1 2 2 2";
    column_meters_1 = "Tasks AllCPUs LoadAverage GPU Systemd SystemdUser";
    column_meter_modes_1 = "2 1 1 1 2 2";
    tree_view = false;
    sort_key = 46;
    tree_sort_key = false;
    sort_direction = -1;
    tree_sort_direction = true;
    tree_view_always_by_pid = false;
    all_branches_collapsed = false;
  };
}
