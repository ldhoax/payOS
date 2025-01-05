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

      def confirm_webhook(webhook_url)
        @client.post(PayOS::CONFIRM_WEBHOOK_PATH, { "webhookUrl" => webhook_url })
      end

      private

      def params_with_signature(params)
        formatted_params = Utils::Formater.format_params(params)
        string_to_sign = Utils::Formater.params_to_string(formatted_params)

        formatted_params["signature"] = Utils::Signature.generate(string_to_sign, PayOS.configuration.checksum_secret)

        formatted_params
      end
    end
  end
end
