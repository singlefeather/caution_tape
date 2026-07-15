# frozen_string_literal: true

module CautionTape
  # Auto-installs the middleware in Rails applications.
  class Railtie < ::Rails::Railtie
    initializer "caution_tape.middleware" do |app|
      app.middleware.use CautionTape::Middleware
    end
  end
end
