# encoding: UTF-8

require "openssl"
require "json"

module PrometheusGCPSSLCerts
  class Collector
    module Registry
      module GCP
        def self.certificate_cache
          @cache ||= certificates
        end

        def self.cache_clear
          @cache = nil
        end

        def self.certificates
          json = `gcloud --format json compute ssl-certificates list`

          begin
            data = JSON.parse(json)
          rescue
            raise StandardError, "failed to parse ssl certificate JSON"
          end

          data.map do |cert_data|
            cert = OpenSSL::X509::Certificate.new(cert_data["certificate"])
            cert.subject.to_s.sub("/CN=", "")
          end
        end

        def self.defunct_certificates(registry)
          registry.metrics.flat_map do |metric|
            next unless metric.name == :gcp_ssl_cert_expiration

            metric.values.flat_map do |gauge, value|
              gauge[:certificate_name] unless certificate_cache.include? gauge[:certificate_name]
            end
          end.delete_if { |e| e.nil? }
        end
      end
    end
  end
end
