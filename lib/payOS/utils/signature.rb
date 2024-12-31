# frozen_string_literal: true

module PayOS
  module Utils
    class Signature
      def self.generate(data, secret_key)
        OpenSSL::HMAC.hexdigest('SHA256', secret_key, data)
      end
    end
  end
end