# frozen_string_literal: true

RSpec.describe PayOS do
  let(:config) do
    PayOS::Configuration.new.tap do |c|
      c.client_id = "test_client_id"
      c.api_key = "test_api_key"
      c.checksum_secret = "test_secret"
      c.partner_code = "test_partner"
    end
  end

  describe "module methods" do
    before do
      PayOS.configure do |c|
        c.client_id = config.client_id
        c.api_key = config.api_key
        c.checksum_secret = config.checksum_secret
        c.partner_code = config.partner_code
      end
    end

    describe ".create_payment_url" do
      it "creates a payment URL" do
        params = {
          orderCode: "order_123",
          amount: 1000,
          description: "Test payment",
          cancelUrl: "http://example.com/cancel",
          returnUrl: "http://example.com/return",
          signature: "test_signature"
        }

        expect(PayOS.payment_service).to receive(:create).with(params)
        PayOS.create_payment_url(params)
      end
    end

    describe ".get_payment_info" do
      it "retrieves payment information" do
        payment_url_id = "test_payment_id"

        expect(PayOS.payment_service).to receive(:get_info).with(payment_url_id)
        PayOS.get_payment_info(payment_url_id)
      end
    end

    describe ".cancel_payment" do
      it "cancels a payment" do
        payment_url_id = "test_payment_id"

        expect(PayOS.payment_service).to receive(:cancel).with(payment_url_id)
        PayOS.cancel_payment(payment_url_id)
      end
    end

    describe ".confirm_webhook" do
      it "confirms a webhook URL" do
        webhook_url = "http://example.com/webhook"

        expect(PayOS.payment_service).to receive(:confirm_webhook).with(webhook_url)
        PayOS.confirm_webhook(webhook_url)
      end
    end

    describe ".verify_request!" do
      it "verifies webhook data signature" do
        data = { "orderId" => "123", "amount" => 1000 }
        signature = "test_signature"
        string_to_sign = "amount=1000&orderId=123"

        expect(PayOS::Utils::Formater).to receive(:webhook_data_to_string)
          .with(data)
          .and_return(string_to_sign)

        expect(PayOS::Utils::Signature).to receive(:verify!)
          .with(string_to_sign, PayOS.configuration.checksum_secret, signature)

        PayOS.verify_request!(data, signature)
      end
    end
  end

  describe "instance methods" do
    let(:payos) { PayOS::PayOS.new(config) }

    describe "#create_payment_url" do
      it "creates a payment URL" do
        params = {
          orderCode: "order_123",
          amount: 1000,
          description: "Test payment",
          cancelUrl: "http://example.com/cancel",
          returnUrl: "http://example.com/return",
          signature: "test_signature"
        }

        expect(payos.payment_service).to receive(:create).with(params)
        payos.create_payment_url(params)
      end
    end

    describe "#get_payment_info" do
      it "retrieves payment information" do
        payment_url_id = "test_payment_id"

        expect(payos.payment_service).to receive(:get_info).with(payment_url_id)
        payos.get_payment_info(payment_url_id)
      end
    end

    describe "#cancel_payment" do
      it "cancels a payment" do
        payment_url_id = "test_payment_id"

        expect(payos.payment_service).to receive(:cancel).with(payment_url_id)
        payos.cancel_payment(payment_url_id)
      end
    end

    describe "#confirm_webhook" do
      it "confirms a webhook URL" do
        webhook_url = "http://example.com/webhook"

        expect(payos.payment_service).to receive(:confirm_webhook).with(webhook_url)
        payos.confirm_webhook(webhook_url)
      end
    end

    describe "#verify_request!" do
      it "verifies webhook data signature" do
        data = { "orderId" => "123", "amount" => 1000 }
        signature = "test_signature"
        string_to_sign = "amount=1000&orderId=123"

        expect(PayOS::Utils::Formater).to receive(:webhook_data_to_string)
          .with(data)
          .and_return(string_to_sign)

        expect(PayOS::Utils::Signature).to receive(:verify!)
          .with(string_to_sign, config.checksum_secret, signature)

        payos.verify_request!(data, signature)
      end
    end
  end
end
