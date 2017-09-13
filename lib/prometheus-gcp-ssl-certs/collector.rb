# encoding: UTF-8

require "prometheus/client"

require "prometheus-gcp-ssl-certs/prometheus"
require "prometheus-gcp-ssl-certs/collector"
require "prometheus-gcp-ssl-certs/collector/registry"
require "prometheus-gcp-ssl-certs/collector/registry/gcp"
require "prometheus-gcp-ssl-certs/collector/registry/ssl"

module PrometheusGCPSSLCerts
  class Collector
    attr_reader :app, :registry

    def initialize(app)
      @app      = app
      @registry = Prometheus::Client.registry
      @gauge    = @registry.gauge(
        :gcp_ssl_cert_expiration,
        'GCP SSL certificate - expiration date (seconds since epoch)',
      )
    end

    def call(env)
      @registry, @gauge = Registry.update(@registry, @gauge)

      @app.call(env)
    end
  end
end
