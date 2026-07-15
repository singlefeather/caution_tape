# frozen_string_literal: true

module CautionTape
  # Builds the HTML fragment (styles + frame + banner/tag) injected into pages.
  module Renderer
    module_function

    def html(config)
      parts = [+"<style>#{css(config)}</style>"]
      parts << %(<div class="caution-tape-frame" aria-hidden="true"></div>)
      if config.banner
        parts << %(<div class="caution-tape-banner" role="status">#{escape(config.banner)}</div>)
      elsif config.tag
        parts << %(<div class="caution-tape-tag" aria-hidden="true">#{escape(config.tag)}</div>)
      end
      parts.join
    end

    def css(config)
      [frame_css(config), pill_css(config)].join
    end

    def frame_css(config)
      border = if config.style == :stripes
                 "border:#{config.border_width}px solid;" \
                 "border-image:repeating-linear-gradient(45deg,#1a1a1a 0 16px," \
                 "#{config.color} 16px 32px) #{config.border_width};"
               else
                 "border:#{config.border_width}px solid #{config.color};"
               end
      ".caution-tape-frame{position:fixed;inset:0;pointer-events:none;z-index:2147483000;#{border}}"
    end

    def pill_css(config)
      base = "position:fixed;top:0;left:50%;transform:translateX(-50%);z-index:2147483001;" \
             "pointer-events:none;font:700 12px/1.4 system-ui,sans-serif;letter-spacing:.08em;" \
             "text-transform:uppercase;padding:6px 16px;border-radius:0 0 8px 8px;"
      banner = ".caution-tape-banner{#{base}background:#1a1a1a;color:#{config.color};" \
               "box-shadow:0 2px 8px rgba(0,0,0,.35);}"
      tag = ".caution-tape-tag{#{base}background:#{config.color};color:#fff;}"
      banner + tag
    end

    def escape(text)
      text.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
    end
  end
end
