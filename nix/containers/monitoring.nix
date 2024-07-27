{ config, ... }: {
  services.cadvisor = {
    enable = true;
    port = 3022;
    extraOptions = [
      "--docker_only=false"
      "-housekeeping_interval=10s"
    ];
  };

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 3020;
    webExternalUrl = "/prometheus/";
    checkConfig = true;

    exporters = {
      node = {
        enable = true;
        port = 3021;
        enabledCollectors = ["systemd"];
      };
    };

    scrapeConfigs = [
      {
        job_name = "node_exporter";
        scrape_interval = "50s";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            ];
          }
        ];
      }
      {
        job_name = "cadvisor";
        scrape_interval = "50s";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.cadvisor.port}"
            ];
          }
        ];
      }
    ];
  };

  services.grafana = {
    enable = true;

    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3010;
      };

      analytics = {
        reporting_enabled = false;
        feedback_links_enabled = false;
      };
    };

    provision = {
      enable = true;
      dashboards.settings.providers = [
        {
          # this tells grafana to look at the path for dashboards
          options.path = "/etc/grafana/dashboards";
        }
      ];
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://127.0.0.1:${toString config.services.prometheus.port}/prometheus";
        }
      ];
    };
  };
}
