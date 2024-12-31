# frozen_string_literal: true

module PayOS
  class Error < StandardError; end
  class SignatureVerificationError < Error; end
  class RateLimitError < Error; end
  class APIError < Error; end
end
