# frozen_string_literal: true

RSpec.describe PayOS::Models::Response do
  let(:checksum_secret) { "test_secret" }

  describe "#verify_signature!" do
    it "returns true when data is nil" do
      response = described_class.new({ "code" => "00", "desc" => "Success" }, checksum_secret)
      expect(response.verify_signature!).to be true
    end

    it "returns true when signature is nil" do
      response = described_class.new({
                                       "code" => "00",
                                       "desc" => "Success",
                                       "data" => { "orderCode" => "ORDER123" }
                                     }, checksum_secret)
      expect(response.verify_signature!).to be true
    end

    it "handles empty data hash correctly" do
      response_body = {
        "code" => "00",
        "desc" => "Success",
        "data" => {}
      }
      response = described_class.new(response_body, checksum_secret)
      expect(response.verify_signature!).to be true
    end

    it "verifies signature with multiple data fields" do
      data = {
        "orderCode" => "ORDER123",
        "amount" => "1000",
        "description" => "Test payment",
        "paymentUrl" => "https://pay.payos.vn/123"
      }

      string_to_sign = "amount=1000&description=Test payment&orderCode=ORDER123&paymentUrl=https://pay.payos.vn/123"
      signature = OpenSSL::HMAC.hexdigest("SHA256", checksum_secret, string_to_sign)

      response_body = {
        "code" => "00",
        "desc" => "Success",
        "data" => data.merge("signature" => signature)
      }

      response = described_class.new(response_body, checksum_secret)
      expect { response.verify_signature! }.not_to raise_error
    end

    it "verifies valid signature" do
      # Create test data
      data = {
        "paymentUrl" => "https://pay.payos.vn/123",
        "orderCode" => "ORDER123"
      }

      # Generate signature
      string_to_sign = "orderCode=ORDER123&paymentUrl=https://pay.payos.vn/123"
      signature = OpenSSL::HMAC.hexdigest("SHA256", checksum_secret, string_to_sign)

      # Create response with signature
      response_body = {
        "code" => "00",
        "desc" => "Success",
        "data" => data.merge("signature" => signature)
      }

      response = described_class.new(response_body, checksum_secret)
      expect { response.verify_signature! }.not_to raise_error
    end

    it "raises error for invalid signature" do
      response_body = {
        "code" => "00",
        "desc" => "Success",
        "data" => {
          "paymentUrl" => "https://pay.payos.vn/123",
          "orderCode" => "ORDER123",
          "signature" => "invalid_signature"
        }
      }

      response = described_class.new(response_body, checksum_secret)
      expect { response.verify_signature! }.to raise_error(PayOS::SignatureVerificationError)
    end
  end

  describe "#success?" do
    it "returns true when code is 00" do
      response = described_class.new({ "code" => "00" }, checksum_secret)
      expect(response.success?).to be true
    end

    it "returns false when code is not 00" do
      response = described_class.new({ "code" => "01" }, checksum_secret)
      expect(response.success?).to be false
    end
  end

  describe "attribute readers" do
    let(:response_body) do
      {
        "code" => "00",
        "desc" => "Success",
        "data" => { "orderCode" => "ORDER123" }
      }
    end

    subject(:response) { described_class.new(response_body, checksum_secret) }

    it "provides access to response attributes" do
      expect(response.code).to eq("00")
      expect(response.desc).to eq("Success")
      expect(response.data).to eq({ "orderCode" => "ORDER123" })
      expect(response.raw_response).to eq(response_body)
    end
  end
end
