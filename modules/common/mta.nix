{ config, lib, ... }: {

  config = lib.mkIf (config.networking.hostName != "sempriaq") {
    # I want to be able to do the follwoing things:
    # - Receive emails from anyone for local users
    # - Have working smtp ports them on standart ports: 25, 465, 587
    # - Receive emails for domains: [ipv4, ipv6], hostname, hostname.local, hostname.antibuild.ing

    # Also I want to to the following things:
    # - Send emails to anyone from local users (via hostname.antibuild.ing) (probably not here)
    # - Have mutt working for every local user
    # - Send emails to ip addresses
    # - Send email inside the antibuild.ing
    # - Send emails to local users
    # - Sending mails to the internet should use a relay to circumvent port 25 blocking
    # - Sending mail to the local network or antibuild.ing should be done directly
    # - Receive emails on for a hostname given by the local network
    networking.firewall = {
      allowedTCPPorts = [ 25 ];
    };

    # We want to send emails with our fqdn. Some programs (neomutt) read it from /etc/mailname
    environment.etc."mailname".text = lib.mkForce "${config.networking.fqdnOrHostName}";

    age.secrets."${config.networking.hostName}_mail_password_postfix_config" = {
      file = ../../secrets + "/${config.networking.hostName}_mail_password_postfix_config.age";
    };

    services.postfix = {
      enable = true;
      # The FQDN of the mail server
      hostname = "${config.networking.fqdnOrHostName}";
      # The domain of the mail server
      domain = "${config.networking.domain}";
      # Send emails with this domain
      origin = "${config.networking.fqdnOrHostName}";
      # Accept emails for these domains
      destination = [
        "${config.networking.hostName}"
        "${config.networking.fqdnOrHostName}"
        "localhost"
        "${config.networking.hostName}.local"
        "localhost"
        "localhost.localdomain"
      ];
      # Only accept emails from local host
      networksStyle = "host";
      networks = null;
      # Enable submissions via port 587 (smtps)
      # A bit useless, because I don't have a certificates for now
      enableSubmissions = true;
      # No relayhost, deliver emails directly
      relayHost = "";
      # Send mail for postmaster to root
      postmasterAlias = "root";
      # # Send mail for root to someone else
      # rootAlias = "lennart";

      # # Use this list instead of the local user database
      # localRecipients = null;

      mapFiles = {
        sasl_password = config.age.secrets."${config.networking.hostName}_mail_password_postfix_config".path;
      };
      config = {
        # The types of mail notifications send to the postmaster
        # For now this is all of them, but I want to turn this down, when I know what I'm doing
        notify_classes = [ "bounce" "2bounce" "delay" "policy" "protocol" "resource" "software" ];
        # The ip addresses of the interfaces postfix should run on
        # https://www.postfix.org/postconf.5.html#inet_interfaces
        inet_interfaces = [ "all" ];
        inet_protocols = [ "ipv4" "ipv6" ];

        smtp_host_lookup = [ "native" "dns" ];
        #disable_dns_lookups = yes
        ignore_mx_lookup_error = "yes";

        smtp_fallback_relay = [ "[sempriaq.antibuild.ing]:submission" ];
        # smtp_fallback_relay = [ "[sempriaq.antibuild.ing]:submission" "smtp:mail.zebre.us:submission" ];

        smtp_sasl_auth_enable = "yes";
        smtp_tls_security_level = "encrypt";
        smtp_sasl_tls_security_options = "noanonymous";
        # smtp_sasl_mechanism_filter = [ "plain" "login" ];
        smtp_sasl_password_maps = "hash:${config.environment.etc.postfix.source}/sasl_password";
        # smtp_sasl_security_options = "";
        smtp_use_tls = "yes";
        # fallback_transport = "smtp:sempriaq.antibuild.ing";
      };
    };
  };
}
