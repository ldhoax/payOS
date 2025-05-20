# frozen_string_literal: true

require "faraday"
require "json"

require_relative "payOS/version"
require_relative "payOS/configuration"
require_relative "payOS/errors"
require_relative "payOS/models/response"
require_relative "payOS/client"
require_relative "payOS/services/payment_url"
require_relative "payOS/utils/formater"
require_relative "payOS/utils/signature"

module PayOS
  class Error < StandardError; end

  class PayOS
    def initialize(config = nil)
      @config = config || Configuration.new
      yield(@config) if block_given?
      @config.validate!
    end

    def client
      @client ||= Client.new(@config)
    end

    def payment_service
      @payment_service ||= Services::PaymentUrl.new(client)
    end

    def create_payment_url(params)
      payment_service.create(params)
    end

    def get_payment_info(payment_url_id)
      payment_service.get_info(payment_url_id)
    end

    def cancel_payment(payment_url_id)
      payment_service.cancel(payment_url_id)
    end

    def confirm_webhook(webhook_url)
      payment_service.confirm_webhook(webhook_url)
    end

    def verify_request!(data, signature)
      string_to_sign = Utils::Formater.webhook_data_to_string(data)
      Utils::Signature.verify!(string_to_sign, @config.checksum_secret, signature)
    end
  end

  # For backward compatibility
  def self.configure
    @config ||= Configuration.new
    yield(@config)
    @config.validate!
  end

  def self.client
    @client ||= Client.new(configuration)
  end

  def self.payment_service
    @payment_service ||= Services::PaymentUrl.new(client)
  end

  def self.configuration
    return @config if @config

    @config = Configuration.new
    yield(@config) if block_given?
    @config.validate!
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

  def self.verify_request!(data, signature)
    # raise ForbiddenError if request_source != PayOS::BASE_URL

    # verify signature
    string_to_sign = Utils::Formater.webhook_data_to_string(data)
    Utils::Signature.verify!(string_to_sign, configuration.checksum_secret, signature)
  end
end
