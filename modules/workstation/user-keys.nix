{ config, ... }:
{
  # age.identityPaths = [ config.age.secrets.lennart_ed25519.path ];
  age.secrets.lennart_ed25519 = {
    file = ../../secrets + "/lennart_ed25519.age";
    owner = "lennart";
    group = config.users.users.lennart.group;
    mode = "0400";
    path = "/home/lennart/.ssh/id_ed25519";
    # # Copy the key, because it is used to decrypt the other keys
    # symlink = false;
  };
  age.secrets.lennart_ed25519_pub = {
    file = ../../secrets + "/lennart_ed25519_pub.age";
    owner = "lennart";
    group = config.users.users.lennart.group;
    mode = "0444";
    path = "/home/lennart/.ssh/id_ed25519.pub";
    # symlink = false;
  };

  age.secrets.lennart_backup_append_only_ed25519 = {
    file = ../../secrets/lennart_backup_append_only_ed25519.age;
    owner = "lennart";
    group = config.users.users.lennart.group;
    mode = "0400";
    path = "/home/lennart/.ssh/lennart_backup_append_only_ed25519";
  };
  age.secrets.lennart_backup_append_only_ed25519_pub = {
    file = ../../secrets/lennart_backup_append_only_ed25519_pub.age;
    owner = "lennart";
    group = config.users.users.lennart.group;
    mode = "0444";
    path = "/home/lennart/.ssh/lennart_backup_append_only_ed25519.pub";
  };
}
