{
  self',
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (builtins)
    elemAt
    head
    isAttrs
    isBool
    isInt
    isList
    isPath
    isString
    length
    listToAttrs
    readFile
    tail
    ;
  inherit (lib)
    attrNames
    attrsToList
    concatMap
    concatStringsSep
    getExe
    getName
    mapAttrsToList
    mkIf
    mkOption
    mod
    optional
    optionals
    pipe
    range
    types
    ;
  inherit (lib.generators) mkLuaInline;
  inherit (pkgs) callPackage;

  brightness = "${getExe self'.packages.brightness} --no-notification";
  hyprshot = getExe pkgs.hyprshot;
  mpc = getExe pkgs.mpc;
  rofi = getExe (
    pkgs.rofi.override {
      plugins = [
        pkgs.rofi-emoji
        pkgs.rofi-calc
      ];
    }
  );
  terminal = getName config.flake.defaultApplications.terminal;
  volume = "${getExe self'.packages.volume} --no-notification";
  wlogout = getExe pkgs.wlogout;
  woomer = getExe pkgs.woomer;

  hyprshot_dir = "${config.xdg.userDirs.pictures}/hyprshot/";

  hyprbinds = getExe (callPackage ./hyprbinds { });

  cfg = config.wayland.windowManager.hyprland;

  # Render Nix values as Lua literals.
  toLua =
    value:
    if isAttrs value then
      "{ ${concatStringsSep ", " (mapAttrsToList (key: v: "${key} = ${toLua v}") value)} }"
    else if isList value then
      "{ ${concatStringsSep ", " (map toLua value)} }"
    else if isString value then
      ''"${value}"''
    else if isInt value then
      toString value
    else if isBool value then
      if value then "true" else "false"
    else
      toString value;

  # Turn a structural call such as `{ dsp.exec_cmd = [ "kitty" ]; }` into the
  # Lua expression `hl.dsp.exec_cmd("kitty")`.
  toLuaCall =
    call:
    let
      getPathAndValue =
        path: value:
        if isAttrs value then
          let
            nextKey = head (attrNames value);
          in
          getPathAndValue (path ++ [ nextKey ]) value.${nextKey}
        else
          {
            inherit path;
            inherit value;
          };
      firstKey = head (attrNames call);
      pv = getPathAndValue [ firstKey ] call.${firstKey};
    in
    "hl.${concatStringsSep "." pv.path}(${concatStringsSep ", " (map toLua pv.value)})";

  # Project the grouped declaration into the `{ _args = ...; }` bindings
  # home-manager expects for `settings.bind`.
  projectBinds =
    binds:
    pipe binds [
      attrsToList
      (map (
        bind:
        let
          keys = bind.name;

          call = pipe bind.value [
            head
            (
              call:
              if isAttrs call then
                toLuaCall call
              else if isPath call then
                readFile call
              else
                call
            )
            mkLuaInline
          ];
          opts = tail bind.value;
        in
        {
          _args = [
            keys
            call
          ]
          ++ optionals (opts != [ ]) opts;
        }
      ))
    ];
in
{
  options.wayland.windowManager.hyprland.binds = mkOption {
    type = types.attrsOf (
      types.listOf (
        types.oneOf [
          (types.attrsOf types.anything)
          types.path
          types.str
        ]
      )
    );
    description = ''
      Key bindings grouped by key combination. Each key maps to a list whose
      first attribute set describes the `hl.` call (its function path and
      arguments as Nix expressions), followed by an optional attribute set of
      bind options. They are projected into the flat `settings.bind` array
      expected by home-manager.
    '';
    default = {
      "SUPER + Return" = [
        { dsp.exec_cmd = [ terminal ]; }
        { description = "Launch Terminal"; }
      ];
      "SUPER + C" = [
        { dsp.window.close = [ ]; }
        { description = "Close Window"; }
      ];
      "SUPER + SHIFT + C" = [
        { dsp.window.kill = [ ]; }
        { description = "Kill Window"; }
      ];
      "SUPER + SHIFT + Q" = [
        { dsp.exit = [ ]; }
        { description = "Exit Hyprland"; }
      ];

      # "SUPER + SHIFT + R" = [
      #   { dsp.reload_config = [ ]; }
      #   { description = "Reload Config"; }
      # ];

      # Show current Hyprland binds
      "SUPER + apostrophe" = [
        { dsp.exec_cmd = [ hyprbinds ]; }
        { description = "Show Current Binds"; }
      ];

      "SUPER + Space" = [
        { dsp.window.float = [ { action = "toggle"; } ]; }
        { description = "Toggle Floating Window"; }
      ];
      "SUPER + SHIFT + Return" = [
        {
          dsp.window.fullscreen = [
            {
              action = "toggle";
              mode = "maximized";
            }
          ];
        }
        { description = "Toggle Maximized Fullscreen"; }
      ];

      # Focus
      "SUPER + H" = [
        { dsp.focus = [ { direction = "left"; } ]; }
        { description = "Focus Left"; }
      ];
      "SUPER + L" = [
        { dsp.focus = [ { direction = "right"; } ]; }
        { description = "Focus Right"; }
      ];
      "SUPER + K" = [
        { dsp.focus = [ { direction = "up"; } ]; }
        { description = "Focus Up"; }
      ];
      "SUPER + J" = [
        { dsp.focus = [ { direction = "down"; } ]; }
        { description = "Focus Down"; }
      ];
      "ALT + TAB" = [
        { dsp.window.cycle_next = [ ]; }
        { description = "Cycle Next Window"; }
      ];
      "SUPER + TAB" = [
        { dsp.focus = [ { last = true; } ]; }
        { description = "Focus Last Window"; }
      ];
      "SUPER + right" = [
        { dsp.focus = [ { workspace = "e+1"; } ]; }
        { description = "Focus Next Workspace"; }
      ];
      "SUPER + left" = [
        { dsp.focus = [ { workspace = "e-1"; } ]; }
        { description = "Focus Previous Workspace"; }
      ];
      "SUPER + CTRL + right" = [
        { dsp.focus = [ { monitor = "+1"; } ]; }
        { description = "Focus Next Monitor"; }
      ];
      "SUPER + CTRL + left" = [
        { dsp.focus = [ { monitor = "-1"; } ]; }
        { description = "Focus Previous Monitor"; }
      ];

      # Move and resize windows
      "SUPER + SHIFT + H" = [
        { dsp.window.move = [ { direction = "left"; } ]; }
        { description = "Move Window Left"; }
      ];
      "SUPER + SHIFT + L" = [
        { dsp.window.move = [ { direction = "right"; } ]; }
        { description = "Move Window Right"; }
      ];
      "SUPER + SHIFT + K" = [
        { dsp.window.move = [ { direction = "up"; } ]; }
        { description = "Move Window Up"; }
      ];
      "SUPER + SHIFT + J" = [
        { dsp.window.move = [ { direction = "down"; } ]; }
        { description = "Move Window Down"; }
      ];
      "SUPER + ALT + R" = [
        { dsp.submap = [ "resize" ]; }
        { description = "Enter Resize Mode"; }
      ];
      "SUPER + CTRL + SHIFT + right" = [
        {
          dsp.window.move = [
            {
              monitor = "+1";
              follow = true;
            }
          ];
        }
        { description = "Move Window to Next Monitor"; }
      ];
      "SUPER + CTRL + SHIFT + left" = [
        {
          dsp.window.move = [
            {
              monitor = "-1";
              follow = true;
            }
          ];
        }
        { description = "Move Window to Previous Monitor"; }
      ];

      # Move the current workspace between monitors
      "SUPER + ALT + SHIFT + right" = [
        { dsp.workspace.move = [ { monitor = "+1"; } ]; }
        { description = "Move Workspace to Next Monitor"; }
      ];
      "SUPER + ALT + SHIFT + left" = [
        { dsp.workspace.move = [ { monitor = "-1"; } ]; }
        { description = "Move Workspace to Previous Monitor"; }
      ];

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      "SUPER + SHIFT + right" = [
        { dsp.window.move = [ { workspace = "e+1"; } ]; }
        { description = "Move Window to Next Workspace"; }
      ];
      "SUPER + SHIFT + left" = [
        { dsp.window.move = [ { workspace = "e-1"; } ]; }
        { description = "Move Window to Previous Workspace"; }
      ];

      # Screenshots
      "PRINT" = [
        { dsp.exec_cmd = [ "${hyprshot} --mode=output --output-folder='${hyprshot_dir}'" ]; }
        { description = "Screenshot Output"; }
      ];
      "SUPER + PRINT" = [
        { dsp.exec_cmd = [ "${hyprshot} --mode=window --output-folder='${hyprshot_dir}'" ]; }
        { description = "Screenshot Window"; }
      ];
      "SUPER + SHIFT + PRINT" = [
        { dsp.exec_cmd = [ "${hyprshot} --mode=region --output-folder='${hyprshot_dir}'" ]; }
        { description = "Screenshot Region"; }
      ];

      # Emojis
      "SUPER + period" = [
        { dsp.exec_cmd = [ "${rofi} -show emoji" ]; }
        { description = "Open Emoji Picker"; }
      ];

      # wlogout
      "SUPER + F4" = [
        { dsp.exec_cmd = [ "${wlogout} --protocol layer-shell" ]; }
        { description = "Open Logout Menu"; }
      ];

      # Pin Window (Sticky)
      "SUPER + ALT + S" = [
        { dsp.window.pin = [ { action = "active"; } ]; }
        { description = "Pin Window"; }
      ];

      # Named special workspace (scratchpad)
      "SUPER + SHIFT + S" = [
        { dsp.workspace.toggle_special = [ "scratchpad" ]; }
        { description = "Toggle Scratchpad"; }
      ];
      "SUPER + SHIFT + ALT + S" = [
        {
          dsp.window.move = [
            {
              workspace = "special:scratchpad";
              follow = true;
            }
          ];
        }
        { description = "Move Window to Scratchpad"; }
      ];

      "SUPER + F" = [
        { dsp.window.fullscreen = [ { action = "toggle"; } ]; }
        { description = "Toggle Fullscreen"; }
      ];

      # Zoom
      "SUPER + Plus" = [
        { dsp.exec_cmd = [ woomer ]; }
        { description = "Zoom In"; }
      ];
    }
    // listToAttrs (
      map (number: {
        name = "SUPER + ${toString (mod number 10)}";
        value = [
          { dsp.focus = [ { workspace = number; } ]; }
          { description = "Focus Workspace ${toString number}"; }
        ];
      }) (range 1 10)
    )
    // listToAttrs (
      map (number: {
        name = "SUPER + SHIFT + ${toString (mod number 10)}";
        value = [
          { dsp.window.move = [ { workspace = number; } ]; }
          { description = "Move Window to Workspace ${toString number}"; }
        ];
      }) (range 1 10)
    )
    // {
      # Music
      "XF86AudioPlay" = [
        { dsp.exec_cmd = [ "${mpc} toggle" ]; }
        {
          description = "Toggle Playback";
          locked = true;
        }
      ];
      "XF86AudioNext" = [
        { dsp.exec_cmd = [ "${mpc} next" ]; }
        {
          description = "Next Track";
          locked = true;
        }
      ];
      "XF86AudioPrev" = [
        { dsp.exec_cmd = [ "${mpc} prev" ]; }
        {
          description = "Previous Track";
          locked = true;
        }
      ];
      "XF86AudioMute" = [
        { dsp.exec_cmd = [ "${volume} toggle" ]; }
        {
          description = "Toggle Mute";
          locked = true;
        }
      ];

      # Volume
      "XF86AudioRaiseVolume" = [
        { dsp.exec_cmd = [ "${volume} 5 +" ]; }
        {
          description = "Increase Volume";
          locked = true;
          repeating = true;
        }
      ];
      "XF86AudioLowerVolume" = [
        { dsp.exec_cmd = [ "${volume} 5 -" ]; }
        {
          description = "Decrease Volume";
          locked = true;
          repeating = true;
        }
      ];
      "SHIFT + XF86AudioRaiseVolume" = [
        { dsp.exec_cmd = [ "${volume} 1 +" ]; }
        {
          description = "Increase Volume Finely";
          locked = true;
          repeating = true;
        }
      ];
      "SHIFT + XF86AudioLowerVolume" = [
        { dsp.exec_cmd = [ "${volume} 1 -" ]; }
        {
          description = "Decrease Volume Finely";
          locked = true;
          repeating = true;
        }
      ];

      # Brightness
      "XF86MonBrightnessUp" = [
        { dsp.exec_cmd = [ "${brightness} 5 +" ]; }
        {
          description = "Increase Brightness";
          locked = true;
          repeating = true;
        }
      ];
      "XF86MonBrightnessDown" = [
        { dsp.exec_cmd = [ "${brightness} 5 -" ]; }
        {
          description = "Decrease Brightness";
          locked = true;
          repeating = true;
        }
      ];

      # Mouse
      "SUPER + mouse:272" = [
        { dsp.window.drag = [ ]; }
        {
          description = "Drag Window";
          mouse = true;
        }
      ];
      "SUPER + mouse:273" = [
        { dsp.window.resize = [ ]; }
        {
          description = "Resize Window";
          mouse = true;
        }
      ];
      "SUPER + mouse:274" = [
        { dsp.window.center = [ ]; }
        {
          description = "Center Window";
          mouse = true;
        }
      ];

      "SUPER + U" = [
        ./toggle-opacity.lua
        { description = "Toggle opacity"; }
      ];
    };

    example = {
      "SUPER + Return" = [
        { dsp.exec_cmd = [ "kitty" ]; }
        { description = "Launch Terminal"; }
      ];
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    wayland.windowManager.hyprland.settings.bind = projectBinds cfg.binds;

    wayland.windowManager.hyprland.settings.define_submap = {
      _args = [
        "resize"
        (mkLuaInline ''
          function()
              hl.bind("h", hl.dsp.window.resize({ x = -10, y = 0, relative = true }, { repeating = true }))
              hl.bind("l", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
              hl.bind("k", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
              hl.bind("j", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
              hl.bind("Escape", hl.dsp.submap("reset"))
          end
        '')
      ];
    };
  };
}
