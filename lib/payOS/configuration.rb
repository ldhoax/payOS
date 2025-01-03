# frozen_string_literal: true

module PayOS
  class Configuration
    attr_accessor :client_id, :api_key, :checksum_secret, :partner_code

    def initialize
      @client_id = nil
      @api_key = nil
      @checksum_secret = nil
      @partner_code = nil
    end

    def validate!
      raise Error, "client_id is required" if client_id.nil?
      raise Error, "api_key is required" if api_key.nil?
      raise Error, "checksum_secret is required" if checksum_secret.nil?
    end
  end
end
