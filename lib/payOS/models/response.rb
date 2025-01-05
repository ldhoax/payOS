# frozen_string_literal: true

require "openssl"

module PayOS
  module Models
    class Response
      attr_reader :code, :desc, :data, :signature, :raw_response

      def initialize(response_body, checksum_secret)
        @raw_response = response_body
        @code = response_body["code"]
        @desc = response_body["desc"]
        @data = response_body["data"]
        @signature = response_body.dig("data", "signature")
        @checksum_secret = checksum_secret
      end

      def success?
        code == "00"
      end

      def verify_signature!
        return true if @data.nil? || @data["signature"].nil?

        string_to_sign = Utils::Formater.params_to_string(@data.reject { |k, _| k == "signature" })

        Utils::Signature.verify!(string_to_sign, @checksum_secret, @signature)
      end
    end
  end
end
