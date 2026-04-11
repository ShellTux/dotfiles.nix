{ ... }:
{
  genVirtualHosts =
    {
      subdomain,
      allowed-ranges ? "private_ranges",
      domain ? "home",
      reverse-proxy ? null, # AttrSet { .port = { external, internal }; }
      file_serve ? null, # attrSet { port = port; root = "path"; }
    }:
    let
      blocked_tag = "${subdomain}_blocked";
    in
    if reverse-proxy != null then
      let
        inherit (reverse-proxy.port) external internal;
      in
      {
        # "${subdomain}.${domain}".extraConfig = ''
        #   encode zstd gzip
        #
        #   reverse_proxy :${toString external} {
        #     header_up X-Real-IP {remote_host}
        #   }
        # '';

        ":${toString external}".extraConfig = ''
          encode zstd gzip

          @${blocked_tag} not remote_ip ${allowed-ranges}

          header @${blocked_tag} Content-Type "text/html"

          respond @${blocked_tag} 403 {
            body <<HTML
              <html>
                <p>
                  Your IP address is {http.request.remote.host}.
                  You aren't allowed!
                  Ask admin for help.
                </p>
              </html>
            HTML
          }

          import https
          import reverse-proxy 127.0.0.1 ${toString internal}
        '';
      }
    else
      let
        inherit (file_serve) path port;
      in
      {
        ":${toString port}".extraConfig = ''
          encode zstd gzip

          @${blocked_tag} not remote_ip ${allowed-ranges}

          header @${blocked_tag} Content-Type "text/html"

          respond @${blocked_tag} 403 {
            body <<HTML
              <html>
                <p>
                  Your IP address is {http.request.remote.host}.
                  You aren't allowed!
                  Ask admin for help.
                </p>
              </html>
            HTML
          }


          import https
          root * ${path}
          file_server
        '';
      };
}
