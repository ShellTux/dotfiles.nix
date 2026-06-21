{ lib, ... }:
let
  inherit (builtins) filter isString concatStringsSep;
  inherit (lib) pipe;

  protocols = {
    postgresql = {
      string = "postgresql";
      port = 5432;
    };
  };

  mkSqlUri =
    {
      protocol,
      user,
      password ? null,
      host ? "localhost",
      port ? protocols.${protocol}.port,
      db,
    }:
    let
      userPass = pipe [ user password ] [ (filter isString) (concatStringsSep ":") ];
    in
    "${protocol}://${userPass}@${host}:${toString port}/${db}";
in
{
  inherit mkSqlUri;

  mkPostgreSqlUri = args: mkSqlUri (args // { protocol = "postgresql"; });
}
