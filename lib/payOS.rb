# frozen_string_literal: true

require "faraday"
require "json"

require_relative "payOS/version"
require_relative "payOS/configuration"
require_relative "payOS/errors"
require_relative "payOS/models/response"
require_relative "payOS/client"
require_relative "payOS/services/payment_url"

module PayOS
  class Error < StandardError; end

  class << self
    attr_accessor :configuration

    def client
      @client ||= Client.new(configuration)
    end

    def payment_service
      @payment_service ||= Services::PaymentUrl.new(client)
    end
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
    configuration.validate!
  end

  def self.create_payment_url(params)
    payment_service.create(params)
  end

  def self.get_payment_info(payment_url_id)
    payment_service.get_info(payment_url_id)
  end

  def self.cancel_payment(payment_url_id)
    payment_service.cancel(payment_url_id)
  end

  def self.confirm_webhook(webhook_url)
    payment_service.confirm_webhook(webhook_url)
  end

  def self.verify_request!(request_source, data)
    raise ForbiddenError if request_source != PayOS::BASE_URL

    # verify signature
    string_to_sign = Utils::Formater.params_to_string(data)
    Utils::Signature.verify!(string_to_sign, PayOS.configuration.checksum_secret, data["signature"])
  end
end
