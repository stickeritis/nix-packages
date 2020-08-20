{ runCommand }:

{ pkgs, ... } :{

  networking.firewall.allowedTCPPorts = [ 4000 ];

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  systemd.services.sticker = {
    enable = true;
    description = "sticker service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Restart = "on-abort";
      DynamicUser = true;
      ExecStart = runCommand;
    };
  };

  # Set the default root password to 'stickeritis'. Users should change this!
  users.users.root.hashedPassword = "$6$HYsNSILtiizom$YCyX7Hu9mSxR4z/MoTxaMyN8RORMgJv.yBZqXrnJzi/WxzZaszElc33.lRjClqkSGNeARzlmtEVQCH6Q2lpQZ1";
}
