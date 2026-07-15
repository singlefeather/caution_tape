# frozen_string_literal: true

require_relative "caution_tape/version"
require_relative "caution_tape/configuration"
require_relative "caution_tape/renderer"
require_relative "caution_tape/middleware"
require_relative "caution_tape/railtie" if defined?(Rails::Railtie)

# Visual environment indicators for Rack and Rails apps — a striped
# construction frame and banner for sandboxes, a solid frame for dev.
module CautionTape
  class Error < StandardError; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
      configuration
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
