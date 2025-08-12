{
  # File associations (rifle.conf equivalent) - ported from yazi opener config
  programs.ranger.rifle = [
    # Default opener using xdg-open (ported from yazi's open config)
    {
      condition = "else";
      command = "xdg-open \"$1\"";
    }
    
    # Archives - using ouch (ported from yazi's ouch plugin)
    {
      condition = "ext 7z|ace|ar|arc|bz2?|cab|cpio|cpt|deb|dgc|dmg|gz|iso|jar|msi|pkg|rar|shar|tar|tgz|xar|xpi|xz|zip";
      command = "ouch decompress \"$1\"";
    }
    
    # Archives - extract here
    {
      condition = "ext 7z|ace|ar|arc|bz2?|cab|cpio|cpt|deb|dgc|dmg|gz|iso|jar|msi|pkg|rar|shar|tar|tgz|xar|xpi|xz|zip";
      command = "ouch decompress \"$1\" --dir .";
    }
    
    # Office documents (ported from yazi's office plugin)
    {
      condition = "ext docx?|xlsx?|pptx?|odt|ods|odp|sxw";
      command = "libreoffice \"$1\"";
    }
    
    # Office documents - preview
    {
      condition = "ext docx?|xlsx?|pptx?|odt|ods|odp|sxw";
      command = "libreoffice --headless --convert-to pdf --outdir /tmp \"$1\" && xdg-open \"/tmp/$(basename \"$1\" | sed 's/\\.[^.]*$/.pdf/')\"";
    }
    
    # PDF documents
    {
      condition = "ext pdf";
      command = "xdg-open \"$1\"";
    }
    
    # Markdown files (ported from yazi's glow plugin)
    {
      condition = "ext md";
      command = "glow -p \"$1\"";
    }
    
    # Markdown files - edit
    {
      condition = "ext md";
      command = "hx \"$1\"";
    }
    
    # Text files
    {
      condition = "mime ^text|json|xml|javascript";
      command = "hx \"$1\"";
    }
    
    # Configuration files
    {
      condition = "ext conf|config|cfg|ini|toml|yaml|yml";
      command = "hx \"$1\"";
    }
    
    # Images
    {
      condition = "mime ^image";
      command = "xdg-open \"$1\"";
    }
    
    # Videos and Audio (using mediainfo for details, ported from yazi's mediainfo plugin)
    {
      condition = "mime ^video|^audio";
      command = "mediainfo \"$1\" | less";
    }
    
    # Videos and Audio - play
    {
      condition = "mime ^video|^audio";
      command = "xdg-open \"$1\"";
    }
    
    # Web content
    {
      condition = "ext html|htm";
      command = "xdg-open \"$1\"";
    }
    
    # Scripts - make executable and run
    {
      condition = "ext sh|py|pl|rb";
      command = "chmod +x \"$1\" && \"$1\"";
    }
    
    # Scripts - edit
    {
      condition = "ext sh|py|pl|rb|js|ts";
      command = "hx \"$1\"";
    }
    
    # Directories
    {
      condition = "directory";
      command = "cd \"$1\"";
    }
    
    # Binary files - show file info
    {
      condition = "mime ^application";
      command = "file \"$1\" | less";
    }
  ];
}