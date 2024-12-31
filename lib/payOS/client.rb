module PayOS
  class Client
    def initialize(config)
      @config = config
      @http_client = Faraday.new(url: BASE_URL) do |faraday|
        # Set default headers
        faraday.headers['Content-Type'] = 'application/json'
        faraday.headers['x-client-id'] = config.client_id
        faraday.headers['x-api-key'] = config.api_key
        faraday.headers['x-partner-code'] = config.partner_code

        # Add middleware for JSON parsing
        faraday.request :json
        faraday.response :json

        # Add middleware for logging (optional)
        # faraday.response :logger if config.debug_mode

        # Use default adapter
        faraday.adapter Faraday.default_adapter
      end
    end

    def post(path, payload)
      response = @http_client.post(path) do |req|
        req.body = payload.to_json
      end
      
      handle_response(response)
    end

    def get(path)
      response = @http_client.get(path)
      handle_response(response)
    end

    private

    def handle_response(response)
      case response.status
      when 200
        response_obj = Models::Response.new(response.body, @config.checksum_secret)
        # response_obj.verify_signature!
        response_obj
      when 429
        raise RateLimitError, "Rate limit exceeded. Please try again later."
      else
        raise APIError, "API request failed: #{response.body}"
      end
    end
  end
end
