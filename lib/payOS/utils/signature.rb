# frozen_string_literal: true

module PayOS
  module Utils
    class Signature
      def self.generate(data, secret_key)
        OpenSSL::HMAC.hexdigest("SHA256", secret_key, data)
      end

      def self.verify!(data, secret_key, signature)
        raise SignatureVerificationError, "Invalid signature!" if signature.nil?

        return true if OpenSSL::HMAC.hexdigest("SHA256", secret_key, data) == signature

        raise SignatureVerificationError, "Invalid signature!"
      end
    end
  end
end
