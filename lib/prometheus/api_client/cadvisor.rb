# encoding: UTF-8

require 'prometheus/api_client/client'

module Prometheus
  # Client is a ruby implementation for a Prometheus compatible api_client.
  module ApiClient
    # Client contains the implementation for a Prometheus compatible api_client,
    # With special labels for the cadvisor job.
    module Cadvisor
      # Add labels to simple query variables.
      #
      # Example:
      #     "cpu_usage" => "cpu_usage{labels...}"
      #     "sum(cpu_usage)" => "sum(cpu_usage{labels...})"
      #     "rate(cpu_usage[5m])" => "rate(cpu_usage{labels...}[5m])"
      #
      # Note:
      #     Not supporting more complex queries.
      def self.update_query(query, labels)
        query.sub(/(?<r>\[.+\])?(?<f>[)])?$/, "{#{labels}}\\k<r>\\k<f>")
      end

      # A client with special labels for node cadvisor metrics
      class Node < Client
        def initialize(instance, region = 'infra', zone = 'default', args = {})
          @labels = "job=\"kubernetes-cadvisor\",region=\"#{region}\"," \
            "zone=\"#{zone}\",instance=\"#{instance}\""
          super(args)
        end

        def query(options)
          options[:query] = update_query(options[:query], @labels)
          super(options)
        end

        def query_range(options)
          options[:query] = update_query(options[:query], @labels)
          super(options)
        end
      end

      # A client with special labels for pod cadvisor metrics
      class Pod < Client
        def initialize(pod_name, namespace = 'default', region = 'infra',
                       zone = 'default', args = {})

          @labels = "job=\"kubernetes-cadvisor\",region=\"#{region}\"," \
            "zone=\"#{zone}\",namespace=\"#{namespace}\"," \
            "pod_name=\"#{pod_name}\",container_name=\"POD\""
          super(args)
        end

        def query(options)
          options[:query] = update_query(options[:query], @labels)
          super(options)
        end

        def query_range(options)
          options[:query] = update_query(options[:query], @labels)
          super(options)
        end
      end

      # A client with special labels for container cadvisor metrics
      class Container < Client
        def initialize(container_name, pod_name, namespace = 'default',
                       region = 'infra', args = {})

          @labels = "job=\"kubernetes-cadvisor\",region=\"#{region}\"," \
            "namespace=\"#{namespace}\"," \
            "pod_name=\"#{pod_name}\",container_name=\"#{container_name}\""
          super(args)
        end

        def query(options)
          options[:query] = update_query(options[:query], @labels)
          super(options)
        end

        def query_range(options)
          options[:query] = update_query(options[:query], @labels)
          super(options)
        end
      end
    end
  end
end
