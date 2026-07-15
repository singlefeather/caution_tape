# caution_tape 🚧

Visual environment indicators for Rack and Rails apps. Wraps non-production
environments in unmistakable chrome — a striped construction frame and warning
banner for staging/sandbox, a solid colored frame for development — so nobody
ever mistakes a test environment for production (or puts production data in a
sandbox).

- Zero assets, zero JavaScript — a Rack middleware injects a small inline
  `<style>` + two `<div>`s before `</body>` on HTML responses.
- Click-through (`pointer-events: none`) — never blocks the UI.
- Off by default — production is safe unless you explicitly enable it.

## Installation

```bash
bundle add caution_tape
```

## Usage (Rails)

The Railtie installs the middleware automatically. Enable and style it per
environment:

```ruby
# config/environments/development.rb
CautionTape.configure do |c|
  c.enabled = true
  c.style   = :solid
  c.color   = "#dc2626"
  c.tag     = "Dev"
end
```

```ruby
# config/environments/production.rb — same image serves prod and sandbox
CautionTape.configure do |c|
  c.enabled = ENV.fetch("BASE_URL", "").include?("sandbox")
  c.style   = :stripes
  c.banner  = "Sandbox — test environment. Do not enter real data."
end
```

## Usage (plain Rack)

```ruby
CautionTape.configure do |c|
  c.enabled = true
  c.banner  = "Staging"
end

use CautionTape::Middleware
run MyApp
```

## Configuration

| Option | Default | Notes |
|---|---|---|
| `enabled` | `false` | Nothing renders unless enabled |
| `style` | `:stripes` | `:stripes` (caution stripes) or `:solid` |
| `color` | `"#f5c518"` | Accent color; stripes pair it with near-black |
| `banner` | `nil` | Warning pill pinned top-center |
| `tag` | `nil` | Small label pill, shown when no banner is set |
| `border_width` | `10` | Frame thickness in px |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/singlefeather/caution_tape. Contributors are expected to
adhere to the [code of conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
