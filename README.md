# URL
**URL** is a simple URL parser and construction tool for Ruby. It doesn't strictly follow any RFCs — instead, **it behaves as you’d expect**.

## Background
This gem was born out of frustration with the URL handling in Ruby’s standard library and other gems.
I wanted to parse a URL, modify it, and then convert it back to a string. I also wanted to join paths and query strings to URLs without worrying about trailing slashes or question marks.

## Installation
```ruby
gem "qasa-url"
```

## Usage
```ruby
# Initialize a new URL object from a string:
url = URL.parse("http://www.example.com:404/path")
url.to_s # => "http://www.example.com:404/path"

# Modify a URL:
url.scheme = "https"
url.port = nil
url.join("/to")
url.join("/nowhere")
url.to_s # => "https://www.example.com/path/to/nowhere"

# Add a query string:
url.merge(foo: "bar")
url.to_s # => "https://www.example.com/path/to/nowhere?foo=bar"

# Initialize a URL object with just a domain name:
url = URL["example.com"]
url.join("/path", "to", "nowhere")

# Note: If no protocol is provided, it defaults to "https":
url.to_s # => "https://example.com/path/to/nowhere"
```

## Alternatives
If you're looking for something that parses URLs in Ruby and Ruby on Rails and closely conforms to RFC 3986, RFC 3987, and RFC 6570 (level 4), check out [addressable](https://github.com/sporkmonger/addressable).
For domain name validation, see [public_suffix](https://github.com/weppos/publicsuffix-ruby).

## Risks using this gem
The risks of using this gem are very low. It’s small, simple, and well-tested.
The main caveat is that it doesn’t follow any RFCs, so behavior may differ in edge cases. That said, it’s unlikely you’ll encounter issues in practice.

This gem is actively maintained by [Qasa](https://www.qasa.se), a small team of dedicated Ruby developers.

## Contributing
**Bug reports and pull requests are always welcome!**

## License
See [LICENSE](LICENSE).
