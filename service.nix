{ config, lib, pkgs, ... }:

let
  dockerRun =
    import ./default.nix { pkgs = pkgs; };

  cfg =
    config.services.dockerRun;

  commonEnvironment = {
    LC_ALL = "en_US.UTF-8";
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  };
in
{
  options = {
    services.dockerRun = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable rce-engine";
      };

      environment = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Environment variables for the service";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Add rce group
    users.groups.rce = {};

    # Service user
    users.extraUsers.rce = {
      isSystemUser = true;
      group = "rce";
      extraGroups = ["docker"];
      description = "service user";
    };

    # Systemd service
    systemd.services.rce-engine = {
      description = "rce-engine service";
      wantedBy = [ "multi-user.target" ];

      serviceConfig =
        {
          ExecStart = "${dockerRun}/bin/rce-engine";
          Restart = "always";
          User = "rce";
        };

      environment = commonEnvironment // cfg.environment;
    };
  };
}
