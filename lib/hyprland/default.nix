{ ... }:
{
  windowrule =
    let
      effect =
        {
          match, # "class window-class"
          effect,
        }:
        "match:${match}, ${effect}";
    in
    {
      no_anim =
        attrs@{
          no_anim ? "on",
          ...
        }:
        effect ((removeAttrs attrs [ "no_anim" ]) // { effect = "no_anim ${no_anim}"; });
      animation =
        attrs@{
          animation ? "on",
          ...
        }:
        effect ((removeAttrs attrs [ "animation" ]) // { effect = "animation ${animation}"; });
      float =
        attrs@{
          float ? "on",
          ...
        }:
        effect ((removeAttrs attrs [ "float" ]) // { effect = "float ${float}"; });
      fullscreen =
        attrs@{
          fullscreen ? "on",
          ...
        }:
        effect ((removeAttrs attrs [ "fullscreen" ]) // { effect = "fullscreen ${fullscreen}"; });
      idleinhibit =
        attrs@{ idle_inhibit, ... }:
        effect ((removeAttrs attrs [ "idle_inhibit" ]) // { effect = "idle_inhibit ${idle_inhibit}"; });
      stay_focused =
        attrs@{
          stay_focused ? "on",
          ...
        }:
        effect ((removeAttrs attrs [ "stay_focused" ]) // { effect = "stay_focused ${stay_focused}"; });
      border_size =
        attrs@{
          border_size ? 3,
          ...
        }:
        effect (
          (removeAttrs attrs [ "border_size" ]) // { effect = "border_size ${toString border_size}"; }
        );
      center =
        attrs@{
          center ? "on",
          ...
        }:
        effect ((removeAttrs attrs [ "center" ]) // { effect = "center ${center}"; });
      opaque =
        attrs@{
          opaque ? "on",
          ...
        }:
        effect ((removeAttrs attrs [ "opaque" ]) // { effect = "opaque ${opaque}"; });
      pin =
        attrs@{
          pin ? "on",
          ...
        }:
        effect ((removeAttrs attrs [ "pin" ]) // { effect = "pin ${pin}"; });
      size =
        attrs@{ width, height, ... }:
        effect (
          (removeAttrs attrs [
            "width"
            "height"
          ])
          // {
            effect = "size ${width} ${height}";
          }
        );
      workspace = number: attrs: effect (attrs // { effect = "workspace ${toString number}"; });
    };
}
