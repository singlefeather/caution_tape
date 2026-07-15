# frozen_string_literal: true

module CautionTape
  # Rack middleware that injects the environment chrome into HTML responses,
  # just before </body>.
  class Middleware
    BODY_CLOSE = "</body>"

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      config = CautionTape.configuration
      return [status, headers, body] unless config.enabled && html?(headers)

      inject(status, headers, body, config)
    end

    private

    def inject(status, headers, body, config)
      original = read_body(body)
      index = original.rindex(BODY_CLOSE)
      return [status, headers, [original]] unless index

      injected = original.dup
      injected.insert(index, Renderer.html(config))
      [status, update_content_length(headers, injected), [injected]]
    end

    def read_body(body)
      buffer = +""
      body.each { |chunk| buffer << chunk }
      body.close if body.respond_to?(:close)
      buffer
    end

    def update_content_length(headers, injected)
      key = headers.key?("content-length") ? "content-length" : "Content-Length"
      return headers unless headers.key?(key)

      headers.merge(key => injected.bytesize.to_s)
    end

    def html?(headers)
      content_type = headers["content-type"] || headers["Content-Type"]
      content_type&.include?("text/html")
    end
  end
end
