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
    length
    mapAttrs
    match
    readFile
    split
    tail
    typeOf
    ;
  inherit (lib) optional pipe attrsToList;
  inherit (lib.generators) mkLuaInline;

  isValidLuaFile = path: typeOf path == "path" && match ".*\\.lua$" (toString path) != null;

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
  lua = rec {
    mkVar = _var: { inherit _var; };

    mkVars = mapAttrs (name: mkVar);

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

    mkLuaCall =
      args:
      pipe args [
        (map (
          arg:
          if isValidLuaFile arg then
            (mkLuaInline (readFile arg))
          else if isString arg then
            let
              lines = split "\n" arg;

              value =
                if match "^-- mkLuaInline\n.*" arg != null then
                  pipe lines [
                    tail
                    (concatStringsSep "\n")
                    mkLuaInline
                  ]
                else if (length lines) > 1 then
                  mkLuaInline arg
                else
                  arg;
            in
            value
          else
            arg
        ))
        (args: { _args = args; })
      ];
  };
}
