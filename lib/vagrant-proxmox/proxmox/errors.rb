module VagrantPlugins
  module Proxmox
    module ApiError
      class InvalidCredentials < StandardError
      end

      class ConnectionError < StandardError
      end

      class NotImplemented < StandardError
      end

      class ServerError < StandardError
        attr_accessor :response

        def initialize(message = nil, response = nil)
          message = "#{message} Response: #{response.inspect}" unless response.nil?
          super(message)
          self.response = response
        end
      end

      class UnauthorizedError < StandardError
      end
    end
  end
end
