{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.shadowsocks-nodes;
  opts = {
    role = lib.mkOption {
      type = lib.types.enum [
        "server"
        "local"
      ];
    };
    config = lib.mkOption {
      type = lib.types.attrs;
      example.port = 25565;
    };
    passwordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Password file with a password for connecting clients.
      '';
    };
  };
in
{
  options = {
    services.shadowsocks-nodes = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = opts;
        }
      );
    };
  };

  config = {
    assertions = [
      {
        # xor, make sure either password or passwordFile be set.
        # shadowsocks-libev not support plain/none encryption method
        # which indicated that password must set.
        assertion = lib.all (
          node:
          let
            noPasswd = !(node.config ? password);
            noPasswdFile = node.passwordFile == null;
          in
          (noPasswd && !noPasswdFile) || (!noPasswd && noPasswdFile)
        ) (lib.attrValues cfg);
        message = "Option `password` or `passwordFile` must be set and cannot be set simultaneously";
      }
    ];

    systemd.services =
      let
        mapAttrsToAttrs = attrs: f: lib.listToAttrs (lib.mapAttrsToList f attrs);
      in
      mapAttrsToAttrs cfg (
        name: node:
        let
          configFile = pkgs.writeText "shadowsocks.json" (builtins.toJSON node.config);
        in
        {
          name = "shadowsocks-node-${name}";
          value = {
            description = "shadowsocks node '${name}'";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            path = [ pkgs.shadowsocks-rust ] ++ lib.optionals (node.passwordFile != null) [ pkgs.jq ];
            serviceConfig.PrivateTmp = true;
            script =
              lib.optionalString (node.passwordFile != null) ''
                cat ${configFile} | jq --arg password "$(cat "${node.passwordFile}")" '. + { password: $password }' > /tmp/shadowsocks.json
              ''
              + ''
                exec ss${node.role} -c ${if node.passwordFile != null then "/tmp/shadowsocks.json" else configFile}
              '';
          };
        }
      );
  };
}
