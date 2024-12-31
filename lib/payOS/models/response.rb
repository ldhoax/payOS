require 'openssl'

module PayOS
  module Models
    class Response
      attr_reader :code, :desc, :data, :signature, :raw_response

      def initialize(response_body, checksum_secret)
        @raw_response = response_body
        @code = response_body['code']
        @desc = response_body['desc']
        @data = response_body['data']
        @signature = response_body.dig('data', 'signature')
        @checksum_secret = checksum_secret
      end

      def success?
        code == '00'
      end

      def verify_signature!
        return true if @data.nil?
        
        # Remove signature from data before verification
        data_without_signature = @data.reject { |k, _| k == 'signature' }
        
        # Sort parameters alphabetically and create string to verify
        string_to_verify = data_without_signature.sort.to_h
          .map { |k, v| "#{k}=#{v}" }
          .join('&')
        
        # Generate signature
        expected_signature = OpenSSL::HMAC.hexdigest(
          'SHA256', 
          @checksum_secret, 
          string_to_verify
        )

        return true if expected_signature == @signature

        raise SignatureVerificationError, 
          "Invalid signature!"
      end
    end
  end
end