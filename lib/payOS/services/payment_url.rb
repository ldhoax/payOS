# frozen_string_literal: true

require_relative "../constants"
require_relative "../utils/signature"

module PayOS
  module Services
    class PaymentUrl
      def initialize(client)
        @client = client
      end

      def create(params)
        @client.post("#{PayOS::API_VERSION}/#{PayOS::PAYMENT_URL_PATH}", params_with_signature(params))
      end

      def get_info(payment_url_id)
        @client.get("#{PayOS::API_VERSION}/#{PayOS::PAYMENT_URL_PATH}/#{payment_url_id}")
      end

      def cancel(payment_url_id)
        @client.post("#{PayOS::API_VERSION}/#{PayOS::PAYMENT_URL_PATH}/#{payment_url_id}/cancel", {})
      end

      private

      def params_with_signature(params)
        # Generate signature from the formatted params
        formatted_params = params.sort_by { |key, _| key.to_s }.map do |key, value|
          formatted_key = key.to_s.split("_").map.with_index do |word, i|
            i.zero? ? word : word.capitalize
          end.join
          [formatted_key, value]
        end.to_h

        formatted_params["signature"] = Utils::Signature.generate(formatted_params.map do |k, v|
          "#{k}=#{v}"
        end.join("&"), PayOS.configuration.checksum_secret)

        formatted_params
      end
    end
  end
end
