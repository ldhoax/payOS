# frozen_string_literal: true

require_relative "payOS/version"
require_relative "payOS/configuration"

module PayOS
  class Error < StandardError; end
  
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end
end