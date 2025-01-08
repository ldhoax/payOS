# frozen_string_literal: true

RSpec.describe PayOS::Utils::Signature do
  let(:data) { "test_data" }
  let(:secret_key) { "test_secret_key" }
  let(:valid_signature) { OpenSSL::HMAC.hexdigest("SHA256", secret_key, data) }

  describe ".generate" do
    it "generates HMAC SHA256 signature" do
      expect(described_class.generate(data, secret_key)).to eq(valid_signature)
    end
  end

  describe ".verify!" do
    context "when signature is valid" do
      it "returns true" do
        expect(described_class.verify!(data, secret_key, valid_signature)).to be true
      end
    end

    context "when signature is invalid" do
      it "raises SignatureVerificationError" do
        expect do
          described_class.verify!(data, secret_key, "invalid_signature")
        end.to raise_error(PayOS::SignatureVerificationError, "Invalid signature!")
      end
    end

    context "when signature is nil" do
      it "raises SignatureVerificationError" do
        expect do
          described_class.verify!(data, secret_key, nil)
        end.to raise_error(PayOS::SignatureVerificationError, "Invalid signature!")
      end
    end
  end
end
