{ theme }:
{
  home_manager_modules = [
    ({
      programs.foot = {
        enable = true;
        server.enable = false;
        settings = {
          main = {
            term = "xterm-256color";
            font = "Hack:size=14";
            resize-by-cells = "no"; # testing
            locked-title = "yes";
            # bold-text-in-bright - Maybe...
            utmp-helper = "none";
          };

          scrollback = {
            lines = 690000;
            multiplier = 3.0;
          };

          key-bindings = {
            scrollback-up-half-page = "Shift+Page_Up";
            scrollback-down-half-page = "Shift+Page_Down";
            clipboard-copy = "Control+Shift+c XF86Copy";
            clipboard-paste = "Control+Shift+v XF86Paste";
            font-increase = "Control+plus";
            font-decrease = "Control+minus";
            font-reset = "Control+0";

            # disabled default bindings
            scrollback-up-page = "none";
            scrollback-down-page = "none";
            primary-paste = "none";
            spawn-terminal = "none";
            search-start = "none";
            show-urls-launch = "none";
            prompt-prev = "none";
            prompt-next = "none";
            unicode-input = "none";
          };

          mouse-bindings = {
            selection-override-modifiers = "Shift";
            scrollback-up-mouse = "BTN_WHEEL_BACK";
            scrollback-down-mouse = "BTN_WHEEL_FORWARD";
            select-begin = "BTN_LEFT";
            select-begin-block = "Control+Shift+BTN_LEFT";
            select-word = "BTN_LEFT-2";
            select-word-whitespace = "Control+BTN_LEFT-2";
            select-quote = "BTN_LEFT-3";
            select-row = "BTN_LEFT-4";
            select-extend = "BTN_RIGHT";
            select-extend-character-wise = "Control+BTN_RIGHT";
            primary-paste = "BTN_MIDDLE";
            font-increase = "none";
            font-decrease = "none";
          };

          colors = {
            background = "${builtins.replaceStrings ["#"] [""] theme.bg1}";  # Background color
            foreground = "${builtins.replaceStrings ["#"] [""] theme.fg}";   # Foreground color

            alpha = "1.0"; # Transparency level (1.0 = fully opaque)
            
            regular0 = "${builtins.replaceStrings ["#"] [""] theme.black}";   # Black
            regular1 = "${builtins.replaceStrings ["#"] [""] theme.red}";     # Red
            regular2 = "${builtins.replaceStrings ["#"] [""] theme.green}";   # Green
            regular3 = "${builtins.replaceStrings ["#"] [""] theme.yellow}";  # Yellow
            regular4 = "${builtins.replaceStrings ["#"] [""] theme.blue}";    # Blue
            regular5 = "${builtins.replaceStrings ["#"] [""] theme.magenta}"; # Magenta
            regular6 = "${builtins.replaceStrings ["#"] [""] theme.cyan}";    # Cyan
            regular7 = "${builtins.replaceStrings ["#"] [""] theme.white}";   # White

            bright0 = "${builtins.replaceStrings ["#"] [""] theme.black_light}";   # Bright black
            bright1 = "${builtins.replaceStrings ["#"] [""] theme.red_light}";     # Bright red
            bright2 = "${builtins.replaceStrings ["#"] [""] theme.green_light}";   # Bright green
            bright3 = "${builtins.replaceStrings ["#"] [""] theme.yellow_light}";  # Bright yellow
            bright4 = "${builtins.replaceStrings ["#"] [""] theme.blue_light}";    # Bright blue
            bright5 = "${builtins.replaceStrings ["#"] [""] theme.magenta_light}"; # Bright magenta
            bright6 = "${builtins.replaceStrings ["#"] [""] theme.cyan_light}";    # Bright cyan
            bright7 = "${builtins.replaceStrings ["#"] [""] theme.white_light}";   # Bright white
          };
        };
      }
    })
  ]
}