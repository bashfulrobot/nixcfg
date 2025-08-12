{
  programs.ranger.settings = {
    # Basic settings ported from yazi
    show_hidden = true;
    sort = "natural";
    sort_case_insensitive = true;
    sort_directories_first = true;
    
    # Preview settings (ported from yazi preview config)
    preview_files = true;
    preview_directories = true;
    preview_images = true;
    preview_images_method = "w3m";
    preview_max_size = 1048576; # 1MB (equivalent to yazi's max_width/height)
    
    # UI settings
    draw_borders = "both";
    draw_progress_bar_in_status_bar = true;
    display_size_in_main_column = true;
    display_size_in_status_bar = true;
    display_tags_in_all_columns = true;
    
    # Behavior settings
    automatically_count_files = true;
    open_all_images = true;
    vcs_aware = true;
    vcs_backend_git = "enabled";
    use_preview_script = true;
    
    # Performance settings
    max_history_size = 20;
    max_console_history_size = 50;
    scroll_offset = 8;
    
    # Filesystem settings
    confirm_on_delete = "multiple";
    save_console_history = true;
    
    # Directory settings
    collapse_preview = true;
    wrap_scroll = false;
    
    # Mouse support
    mouse_enabled = true;
    
    # Terminal title
    update_title = false;
    
    # Bookmarks
    autosave_bookmarks = true;
    save_backtick_bookmark = true;
    
    # Editor
    default_editor = "hx";
  };
}