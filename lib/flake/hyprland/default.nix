{ lib, ... }:
let
  inherit (builtins)
    attrNames
    concatStringsSep
    head
    isAttrs
    isBool
    isInt
    isList
    isString
    mapAttrs
    ;
  inherit (lib) optional pipe attrsToList;
  inherit (lib.generators) mkLuaInline;

  getPathAndValue =
    let
      helper =
        path: value:
        if isAttrs value then
          let
            nextKey = head (attrNames value);
          in
          helper (path ++ [ nextKey ]) value.${nextKey}
        else
          # Base case: we hit the end. Return a list of [ path value ]
          { inherit path value; };
    in
    attrs:
    let
      firstKey = head (attrNames attrs);
    in
    helper [ firstKey ] attrs.${firstKey};

  toLua =
    value:
    if isAttrs value then
      let
        keys = attrNames value;
        dictInside = pipe keys [
          (map (key: {
            inherit key;
            luaValue = toLua value.${key};
          }))
          (map ({ key, luaValue }: "${key} = ${luaValue}"))
          (concatStringsSep ", ")
        ];
      in
      "{ ${dictInside} }"
    else if isList value then
      let
        args = pipe value [
          (map toLua)
          (concatStringsSep ", ")
        ];
      in
      "{ ${args} }"
    else if isString value then
      # TODO: Escape " inside value, to not allow lua injections
      let
        # matchVar = match ''var\(([a-zA-Z_]+)\)'' value;
        matchVar = null;
      in
      if matchVar == null then
        ''"${value}"''
      else
        (pipe matchVar [
          head
          (var: ''" .. ${var} .. "'')
        ])
    else if isInt value then
      toString value
    else if isBool value then
      if value then "true" else "false"
    else
      value;

  toLuaCall =
    value:
    let
      pathAndValue = getPathAndValue value;
      hlCall = concatStringsSep "." pathAndValue.path;
      args = pipe pathAndValue.value [
        (map toLua)
        (concatStringsSep ", ")
      ];
    in
    "hl.${hlCall}(${args})";

in
{
  window-rule-helper = {
    float = rule: rule // { float = true; };
    idle_inhibit = focus: rule: rule // { idle_inhibit = focus; };
    center = rule: rule // { center = true; };
    fullscreen = rule: rule // { fullscreen = true; };
    pin = rule: rule // { pin = true; };
  };

  lua = rec {
    mkVar = _var: { inherit _var; };

    mkVars = mapAttrs (name: value: mkVar value);

    mkEnvVars =
      varsAttr:
      pipe varsAttr [
        attrsToList
        (map (
          { name, value }:
          {
            _args = [
              name
              value
            ];
          }
        ))
      ];

    mkEnvVar = var: value: {
      _args = map mkLuaInline [
        var
        value
      ];
    };

    mkExecOnce =
      program:
      let
        programs =
          if isList program then
            program
          else if isString program then
            [ program ]
          else
            throw "Error: program must be either string or list";

        functionBody = pipe programs [
          (map (program: toLua program))
          (map (program: "hl.exec_cmd(${program})"))
          (concatStringsSep "\n")
        ];
      in
      (mkLuaInline ''
        function()
            ${functionBody}
        end
      '');

    mkOnStart = cmds: {
      _args = [
        "hyprland.start"
        (mkExecOnce cmds)
      ];
    };

    mkWindowRule = rule: { _args = [ (mkLuaInline (toLua rule)) ]; };

    mkWindowRuleCenter = rule: mkWindowRule (rule // { center = true; });
    mkWindowRuleWorkspace = workspace: rule: mkWindowRule (rule // { workspace = toString workspace; });
    mkWindowRuleBorderSize = border_size: rule: mkWindowRule (rule // { inherit border_size; });
    mkWindowRuleFloat = rule: mkWindowRule (rule // { float = true; });
    mkWindowRuleFullscreen = rule: mkWindowRule (rule // { fullscreen = true; });
    mkWindowRuleIdleInhibit = idle_inhibit: rule: mkWindowRule (rule // { inherit idle_inhibit; });
    mkWindowRuleOpaque = rule: mkWindowRule (rule // { opaque = true; });
    mkWindowRulePin = rule: mkWindowRule (rule // { pin = true; });
    mkWindowRuleSize = size: rule: mkWindowRule (rule // { inherit size; });

    mkWorkspaceRule =
      rule@{ workspace, ... }:
      {
        _args = [ (mkLuaInline (toLua rule)) ];
      };

    mkBinds =
      binds:
      pipe binds [
        attrsToList
        (map ({ name, value }: { keys = name; } // value))
        (map mkBind)
      ];

    mkBind =
      args@{
        keys,
        opts ? { },
        ...
      }:
      let
        keysConcat =
          if isList keys then
            concatStringsSep " + " keys
          else if isString keys then
            keys
          else
            throw "Error: keys must be either list or string";
      in
      {
        _args = [
          keysConcat
          (mkLuaInline (
            toLuaCall (
              removeAttrs args [
                "keys"
                "opts"
              ]
            )
          ))
        ]
        ++ optional (opts != { }) (mkLuaInline (toLua opts));
      };

    mkOptsBind = opts: args@{ keys, ... }: mkBind (args // { inherit opts; });

    mkOptsBinds =
      opts: binds:
      pipe binds [
        attrsToList
        (map ({ name, value }: { keys = name; } // value))
        (map (mkOptsBind opts))
      ];
  };
}
