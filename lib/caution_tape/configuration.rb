# frozen_string_literal: true

module CautionTape
  # Runtime configuration for the injected chrome.
  class Configuration
    STYLES = %i[stripes solid].freeze

    # Whether any chrome is rendered at all. Defaults to off so production
    # is safe by default — enable explicitly per environment.
    attr_accessor :enabled

    # :stripes — diagonal caution stripes (accent color + black).
    # :solid   — a plain frame in the accent color.
    attr_reader :style

    # Accent color. Stripes pair it with near-black; solid uses it alone.
    attr_accessor :color

    # Full-width warning pill pinned top-center, e.g.
    # "Sandbox — do not enter real data." nil renders no banner.
    attr_accessor :banner

    # Small label pill (e.g. "Dev") shown when no banner is set. nil hides it.
    attr_accessor :tag

    # Frame thickness in px.
    attr_accessor :border_width

    def initialize
      @enabled      = false
      @style        = :stripes
      @color        = "#f5c518"
      @banner       = nil
      @tag          = nil
      @border_width = 10
    end

    def style=(value)
      value = value.to_sym
      raise ArgumentError, "style must be one of #{STYLES.join(", ")}" unless STYLES.include?(value)

      @style = value
    end
  end
end
