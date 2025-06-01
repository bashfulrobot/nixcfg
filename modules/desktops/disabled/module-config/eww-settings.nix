{
  user-settings,
  ...
}:
{
  home-manager.users."${user-settings.user.username}" = {
    home.file = {
      # Create the directory structure for eww icons
      ".config/eww/icons/gh/issue_icon.svg" = {
        source = ./assets/gh/issue_icon.svg;
      };

      ".config/eww/icons/gh/pr_icon.svg" = {
        source = ./assets/gh/pr_icon.svg;
      };

      ".config/eww/eww.yuck" = {
        text = ''
          (include "./windows/gh_pr.yuck")
          (include "./windows/gh_issues.yuck")
          (include "./windows/calendar.yuck")
          (include "./windows/tray.yuck")

          (defwidget closer [window]
            (button
              :onclick "eww close ''${window} || true && eww close ''${window}-closer || true"))

          (defwidget iconbox [icon-path class]
            (box
              :class "icon-box"
              (image
                :class "''${class}"
                :path "''${icon-path}")))
        '';
      };

      ".config/eww/eww.scss" = {
        text = ''
          {{scss_colors}}

          .github_prs-closer {
              background: transparent;
              opacity: 0;
              * {
                  background: transparent;
                  opacity: 0;
              }
          }

          .github_issues-closer {
              background: transparent;
              opacity: 0;
              * {
                  background: transparent;
                  opacity: 0;
              }
          }

          .calendar-closer {
              background: transparent;
              opacity: 0;
              * {
                  background: transparent;
                  opacity: 0;
              }
          }

          .background {
              background: transparent;
              border: none;
          }

          .menu-container {
              background-color: $base01;
              padding: 8px;
              border: 1px solid $base02;
              border-radius: 8px;
          }

          .menu-header {
              margin-bottom: 16px;
              padding-bottom: 8px;
              border-bottom: 1px solid $base02;
          }

          .header-text {
              color: $base0E;
              font-size: 20px;
              font-weight: bold;
          }

          .section-header {
              font-size: 18px;
              margin: 16px 0 8px 0;
              padding-bottom: 4px;
              border-bottom: 1px solid $base02;
          }

          .section-text {
              color: $base0C;
              font-size: 14px;
              font-weight: bold;
              margin-left: 10px;
          }

          .menu-item {
              padding: 8px;
              margin: 10px 0;
              border-radius: 6px;
              font-size: 16px;
          }

          .menu-item:hover {
              background-color: $base02;
          }

          .gh-number {
              color: $base0D;
              margin-right: 8px;
              font-family: monospace;
          }

          .item-title {
              color: $base05;
          }

          .menu-container scrollbar {
              background-color: $base00;
              border-radius: 8px;
          }

          .menu-container scrollbar slider {
              background-color: $base02;
              border-radius: 8px;
              margin: 2px;
          }

          .menu-container scrollbar slider:hover {
              background-color: $base03;
          }

          .menu-container > box > box:first-child .section-header {
              margin-top: 0;
          }

          .gh-icon {
              margin-right: 8px;
          }

          .tray {
              background-color: $base01;
              padding: 8px;
              border: 1px solid $base02;
              border-radius: 8px;
          }
        '';
      };

      ".config/eww/windows/calendar.yuck" = {
        text = ''
          (defpoll calendar_events :interval "1m"
            `kip get calendar`)

          (defwidget calendar_event [title url dtstart dtend]
            (eventbox
              :onclick "xdg-open ''${url}"
              :cursor "pointer"
              :class "menu-item"
              (box
                :orientation "vertical"
                :space-evenly false
                (box
                  :orientation "horizontal"
                  :space-evenly false
                  :class "section-header"
                  (label
                    :class "item-title"
                    :text title
                    :limit-width 50)
                  (label
                    :class "event-arrow"
                    :text "↗"))
                (box
                  :orientation "horizontal"
                  :space-evenly false
                  :class "event-time"
                  (label
                    :class "event-time-text"
                    :text "''${dtstart} → ''${dtend}")))))

          (defwidget calendar_list []
            (box
              :orientation "vertical"
              :space-evenly false
              :class "menu-container"
              (box
                :class "menu-header"
                :orientation "horizontal"
                (label :text "Calendar Events" :class "header-text"))
              (scroll
                :class "calendar-scroll"
                :height 400
                (box
                  :orientation "vertical"
                  :space-evenly false
                  (for event in calendar_events
                    (calendar_event
                      :title "''${event.title}"
                      :url "''${event.url}"
                      :dtstart "''${event.dtstart}"
                      :dtend "''${event.dtend}"))))))

          (defwindow calendar_events
            :monitor 0
            :geometry (geometry
            :x "1%"
            :y "1%"
            :width "400px"
            :height "500px"
            :anchor "top right")
            :windowtype "dock"
            :wm-ignore false
            (calendar_list))

          (defwindow calendar-closer
            :monitor 0
            :geometry (geometry :width "100%" :height "100%")
            :stacking "fg"
            :focusable false
            (closer :window "calendar_events"))
        '';
      };

      ".config/eww/windows/gh.yuck" = {
        text = '''';
      };

      ".config/eww/windows/gh_issues.yuck" = {
        text = ''
          (defpoll github_issues_assigned :interval "1m" `kip get issues-assigned`)
          (defpoll github_issues_created :interval "1m" `kip get issues-created`)
          (defpoll github_issues_mentioned :interval "1m" `kip get issues-mentioned`)

          (defwidget issue [number title url]
            (eventbox
              :onclick "xdg-open ''${url}"
              :class "menu-item"
              (box
                :orientation "horizontal"
                :space-evenly false
                (iconbox
                  :icon-path "./icons/gh/issue_icon.svg"
                  :class "gh-icon")
                (label
                  :class "gh-number"
                  :text "#''${number}"
                  :limit-width 50)
                (label
                  :class "item-title"
                  :text title
                  :limit-width 50))))

          (defwidget issues_section [title issues]
            (box
              :orientation "vertical"
              :space-evenly false
              (box
                :halign "start"
                :class "section-header"
                :orientation "horizontal"
                (label :text title :class "section-text"))
              (for issue in issues
                (issue
                  :number "''${issue.number}"
                  :title "''${issue.title}"
                  :url "''${issue.url}"))))

          (defwidget github_issues_list []
            (box
              :orientation "vertical"
              :space-evenly false
              :class "menu-container"
              (box
                :class "menu-header"
                :orientation "horizontal"
                (label :text "Issues" :class "header-text"))
              (box
                :orientation "vertical"
                :space-evenly false
                (issues_section
                  :title "Created"
                  :issues github_issues_created)
                (issues_section
                  :title "Assigned"
                  :issues github_issues_assigned)
                (issues_section
                  :title "Mentioned"
                  :issues github_issues_mentioned))))

          (defwindow github_issues
            :monitor 0
            :geometry (geometry
              :x "1%"
              :y "1%"
              :width "400px"
              :anchor "top right")
            :windowtype "dock"
            :wm-ignore false
            :stacking "overlay"
            (github_issues_list))

          (defwindow github_issues-closer
            :monitor 0
            :geometry (geometry :width "100%" :height "100%")
            :stacking "fg"
            :wm-ignore true
            :focusable false
            (closer :window "github_issues"))
        '';
      };

      ".config/eww/windows/gh_pr.yuck" = {
        text = ''
          (defpoll github_prs :interval "1m" `kip get github_prs`)

          (defwidget pr [number title url]
            (eventbox
              :onclick "xdg-open ''${url}"
              :class "menu-item"
              (box
                :orientation "horizontal"
                :space-evenly false
                (iconbox
                  :icon-path "./icons/gh/pr_icon.svg"
                  :class "gh-icon")
                (label
                  :class "gh-number"
                  :text "#''${number}"
                  :limit-width 50)
                (label
                  :class "item-title"
                  :text title
                  :limit-width 50))))

          (defwidget github_prs_list []
            (box
              :orientation "vertical"
              :space-evenly false
              :class "menu-container"
              (box
                :class "menu-header"
                :orientation "horizontal"
                (label :text "Pull Requests" :class "header-text"))
              (box
                :orientation "vertical"
                :space-evenly false
                (for pr in github_prs
                  (pr
                    :number "''${pr.number}"
                    :title "''${pr.title}"
                    :url "''${pr.url}")))))

          (defwindow github_prs
            :monitor 0
            :geometry (geometry
            :x "1%"
            :y "1%"
            :width "400px"
            :anchor "top right")
            :windowtype "dock"
            :wm-ignore false
            :stacking "overlay"
            (github_prs_list))

          (defwindow github_prs-closer
            :monitor 0
            :geometry (geometry :width "100%" :height "100%")
            :stacking "fg"
            :wm-ignore true
            :focusable false
            (closer :window "github_prs"))
        '';
      };

      # Add an empty tray file since it's referenced in eww.yuck
      ".config/eww/windows/tray.yuck" = {
        text = '''';
      };
    };
  };
}
