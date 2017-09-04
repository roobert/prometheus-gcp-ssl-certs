# encoding: UTF-8

module PrometheusGCPSSLCerts
  class Collector
    module Registry
      def self.update(registry, gauge)
        refresh_certificates(gauge)
        purge_defunct_certificates(registry, gauge)

        [ registry, gauge ]
      end

      def self.refresh_certificates(gauge)
        GCP.certificate_cache.each do |host|
          gauge.set({ "certificate_name": host }, SSL.valid_until(host))
        end
      end

      def self.purge_defunct_certificates(registry, gauge)
        GCP.defunct_certificates(registry).each do |host|
          gauge.values.delete_if { |tags, _| tags[:certificate_name] == host }
        end
      end
    end
  end
end
