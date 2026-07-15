# frozen_string_literal: true

require "test_helper"

class TestCautionTape < Minitest::Test
  PAGE = "<html><head></head><body><h1>Hi</h1></body></html>"

  def setup
    CautionTape.reset_configuration!
  end

  def teardown
    CautionTape.reset_configuration!
  end

  def app_response(body: PAGE, content_type: "text/html; charset=utf-8", with_length: false)
    headers = { "content-type" => content_type }
    headers["content-length"] = body.bytesize.to_s if with_length
    ->(_env) { [200, headers, [body]] }
  end

  def middleware_call(app)
    CautionTape::Middleware.new(app).call({})
  end

  def response_body(response)
    (+"").tap { |s| response[2].each { |chunk| s << chunk } }
  end

  def test_disabled_by_default_leaves_response_untouched
    _, _, body = middleware_call(app_response)
    assert_equal PAGE, body.join
  end

  def test_injects_frame_before_body_close_when_enabled
    CautionTape.configure { |c| c.enabled = true }
    body = response_body(middleware_call(app_response))

    assert_includes body, "caution-tape-frame"
    assert_operator body.index("caution-tape-frame"), :<, body.index("</body>")
  end

  def test_stripes_style_uses_repeating_gradient
    CautionTape.configure { |c| c.enabled = true }
    body = response_body(middleware_call(app_response))
    assert_includes body, "repeating-linear-gradient"
  end

  def test_solid_style_uses_plain_border
    CautionTape.configure do |c|
      c.enabled = true
      c.style = :solid
      c.color = "#dc2626"
    end
    body = response_body(middleware_call(app_response))
    assert_includes body, "border:10px solid #dc2626"
    refute_includes body, "repeating-linear-gradient"
  end

  def test_banner_renders_and_is_escaped
    CautionTape.configure do |c|
      c.enabled = true
      c.banner = "Sandbox <em>only</em>"
    end
    body = response_body(middleware_call(app_response))
    assert_includes body, "caution-tape-banner"
    assert_includes body, "Sandbox &lt;em&gt;only&lt;/em&gt;"
  end

  def test_tag_renders_when_no_banner
    CautionTape.configure do |c|
      c.enabled = true
      c.tag = "Dev"
    end
    body = response_body(middleware_call(app_response))
    assert_includes body, "caution-tape-tag"
    assert_includes body, ">Dev<"
  end

  def test_banner_wins_over_tag
    CautionTape.configure do |c|
      c.enabled = true
      c.banner = "Sandbox"
      c.tag = "Dev"
    end
    body = response_body(middleware_call(app_response))
    assert_includes body, "caution-tape-banner"
    refute_includes body, "caution-tape-tag\""
  end

  def test_non_html_responses_untouched
    CautionTape.configure { |c| c.enabled = true }
    _, _, body = middleware_call(app_response(body: "{}", content_type: "application/json"))
    assert_equal "{}", body.join
  end

  def test_html_without_body_close_untouched
    CautionTape.configure { |c| c.enabled = true }
    _, _, body = middleware_call(app_response(body: "<h1>fragment</h1>"))
    assert_equal "<h1>fragment</h1>", body.join
  end

  def test_content_length_updated_when_present
    CautionTape.configure { |c| c.enabled = true }
    _, headers, body = middleware_call(app_response(with_length: true))
    assert_equal body.join.bytesize.to_s, headers["content-length"]
  end

  def test_invalid_style_raises
    assert_raises(ArgumentError) { CautionTape.configure { |c| c.style = :zebra } }
  end

  def test_that_it_has_a_version_number
    refute_nil ::CautionTape::VERSION
  end
end
