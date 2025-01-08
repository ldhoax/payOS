# frozen_string_literal: true

require "spec_helper"

RSpec.describe PayOS::Services::PaymentUrl do
  let(:client) { double("client") }
  let(:config) do
    PayOS::Configuration.new.tap do |c|
      c.client_id = "test_client_id"
      c.api_key = "test_api_key"
      c.checksum_secret = "test_secret"
      c.partner_code = "test_partner"
    end
  end
  let(:service) { described_class.new(client) }

  before do
    allow(PayOS).to receive(:configuration).and_return(config)
  end

  describe "#create" do
    let(:valid_params) do
      {
        "orderCode": "123",
        "amount": 1000,
        "description": "Test",
        "cancelUrl": "http://example.com",
        "returnUrl": "http://example.com"
      }
    end

    it "creates payment request successfully" do
      expect(client).to receive(:post) do |path, params|
        expect(path).to eq("#{PayOS::API_VERSION}/#{PayOS::PAYMENT_URL_PATH}")
        expect(params.transform_keys(&:to_s)).to include(valid_params.transform_keys(&:to_s))
        expect(params).to have_key("signature")
      end
      service.create(valid_params)
    end
  end

  describe "#get_info" do
    it "fetches payment request info" do
      payment_id = "123"
      expect(client).to receive(:get).with(
        "#{PayOS::API_VERSION}/#{PayOS::PAYMENT_URL_PATH}/#{payment_id}"
      )
      service.get_info(payment_id)
    end
  end

  describe "#cancel" do
    it "cancels payment request" do
      payment_id = "123"
      expect(client).to receive(:post).with(
        "#{PayOS::API_VERSION}/#{PayOS::PAYMENT_URL_PATH}/#{payment_id}/cancel",
        {}
      )
      service.cancel(payment_id)
    end
  end

  describe "#params_with_signature" do
    let(:raw_params) do
      {
        order_code: "123",
        amount: 1000,
        return_url: "http://example.com",
        cancel_url: "http://example.com",
        description: "Test payment"
      }
    end

    let(:expected_formatted_params) do
      {
        "orderCode" => "123",
        "amount" => 1000,
        "returnUrl" => "http://example.com",
        "cancelUrl" => "http://example.com",
        "description" => "Test payment"
      }
    end

    it "formats parameters from snake_case to camelCase" do
      result = service.send(:params_with_signature, raw_params)

      expected_formatted_params.each do |key, value|
        expect(result[key]).to eq(value)
      end
    end

    it "adds correct signature to params" do
      result = service.send(:params_with_signature, raw_params)

      expect(result).to have_key("signature")

      # Verify signature is generated from sorted params
      sorted_params = "amount=1000&cancelUrl=http://example.com&description=Test payment&orderCode=123&returnUrl=http://example.com"
      expected_signature = PayOS::Utils::Signature.generate(sorted_params, "test_secret")

      expect(result["signature"]).to eq(expected_signature)
    end
  end

  describe "#confirm_webhook" do
    it "confirms webhook URL" do
      webhook_url = "https://example.com/webhook"
      expect(client).to receive(:post).with(
        PayOS::CONFIRM_WEBHOOK_PATH,
        { "webhookUrl" => webhook_url }
      )
      service.confirm_webhook(webhook_url)
    end
  end
end
