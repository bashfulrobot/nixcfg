{ pkgs, ... }:
{
  # Custom commands and keybindings ported from yazi configuration
  programs.ranger.extraConfig = ''
    # Custom commands ported from yazi functionality
    
    # Drag and drop command (equivalent to yazi's ripdrag binding)
    map <C-n> shell ripdrag %s -anx 2>/dev/null &
    
    # Smart filter (equivalent to yazi's smart-filter plugin)
    map F console filter%space
    
    # Jump to first file (equivalent to yazi's first-non-directory plugin)  
    map G move to=0
    map gg move to=0
    map G move to=-1
    
    # Archive operations (equivalent to yazi's ouch plugin)
    map C shell ouch compress %s %s.zip
    
    # Restore deleted files (equivalent to yazi's restore plugin)
    map R shell trash-restore
    
    # Mount operations (equivalent to yazi's mount plugin)
    map M shell udisksctl mount -b %s
    
    # Quick navigation improvements
    map <Enter> move right=1
    map <BS> move left=1
    
    # Better deletion (move to trash instead of permanent delete)
    map DD shell trash-put %s
    map <Delete> shell trash-put %s
    
    # Quick edit with helix
    map E shell hx %s
    
    # File operations
    map yy copy
    map dd cut
    map pp paste
    map po paste overwrite=True
    map pl paste_symlink relative=False
    map pL paste_symlink relative=True
    map phl paste_hardlink
    map pht paste_hardlinked_subtree
    
    # Directory operations
    map mkd console mkdir%space
    map mkf console touch%space
    
    # Search improvements
    map / console search_inc%space
    map n search_next
    map N search_next forward=False
    
    # View modes
    map i display_file
    map <C-p> chain draw_possible_programs; console open_with%space
    
    # Selection
    map <Space> mark_files toggle=True
    map v mark_files all=True toggle=True
    map V toggle_visual_mode
    map uv mark_files all=True val=False
    
    # Sorting (ported from yazi's natural sort)
    map or set sort=natural
    map oz set sort=random
    map os chain set sort=size; set sort_reverse=False
    map ob chain set sort=basename; set sort_reverse=False
    map on chain set sort=natural; set sort_reverse=False  
    map om chain set sort=mtime; set sort_reverse=False
    map oc chain set sort=ctime; set sort_reverse=False
    map oa chain set sort=atime; set sort_reverse=False
    map ot chain set sort=type; set sort_reverse=False
    map oe chain set sort=extension; set sort_reverse=False
    
    map oR set sort_reverse!
    map or toggle_option sort_reverse
    
    # Hidden files toggle
    map zh set show_hidden!
    
    # Tabs
    map <C-t> tab_new
    map <C-w> tab_close
    map <TAB> tab_move 1
    map <S-TAB> tab_move -1
    
    # Bookmarks (similar to yazi's bookmark functionality)
    map ba console bookmark%space
    map bd console unmark_tag%space
    map br console rename%space
    
    # Quick access to common directories
    map gh cd ~
    map gd cd ~/Downloads
    map gc cd ~/.config
    map gl cd ~/.local
    map gm cd /mnt
    map gu cd /usr
    map gv cd /var
    map gr cd /
    map gt cd ~/.trash
    
    # Terminal integration
    map <C-s> shell fish
    
    # Quick preview toggle
    map zp set preview_files!
    map zi set preview_images!
    map zd set preview_directories!
  '';
}