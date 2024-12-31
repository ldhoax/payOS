require "spec_helper"

RSpec.describe PayOS::Client do
  let(:config) do
    PayOS::Configuration.new.tap do |c|
      c.client_id = 'test_client_id'
      c.api_key = 'test_api_key'
      c.checksum_secret = 'test_secret'
      c.partner_code = 'test_partner'
    end
  end
  let(:client) { described_class.new(config) }
  let(:payload) { { key: 'value' } }
  let(:response_body) { { 'code' => '00', 'desc' => 'Success' } }
  let(:faraday_response) { instance_double('Faraday::Response', status: 200, body: response_body) }

  describe '#handle_response' do
    context 'when response status is 200' do
      it 'verifies the response signature' do
        response = client.send(:handle_response, faraday_response)
        expect(response).to be_a(PayOS::Models::Response)
      end
    end

    context 'when response status is 429' do
      let(:faraday_response) { instance_double('Faraday::Response', status: 429, body: 'Rate limit exceeded') }

      it 'raises a RateLimitError' do
        expect { client.send(:handle_response, faraday_response) }.to raise_error(PayOS::RateLimitError)
      end
    end

    context 'when response status is not 200 or 429' do
      let(:faraday_response) { instance_double('Faraday::Response', status: 500, body: 'Internal server error') }

      it 'raises an APIError' do
        expect { client.send(:handle_response, faraday_response) }.to raise_error(PayOS::APIError)
      end
    end
  end
end
