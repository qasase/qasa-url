# URL
URL is a simple URL parser and construction tool for Ruby. It doesn't follow any RFC, instead, it behaves as you expect.

## Background
This gem was born out of frustration with the URL handling in Ruby's standard library and other gems. I wanted to be able to parse a URL, modify it and then get the modified URL back as a string. I also wanted to be able to join paths and query strings to URLs without having to worry about trailing slashes and question marks.

## Installation
```ruby
gem "qasa-url"
```

## Usage
```ruby
# Initialize a new URL object by parsing a URL string:
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

# Note: If you don't provide a protocol, it'll default to "https":
url.to_s # => "https://example.com/path/to/nowhere"
```

## Alternatives 
If you're looking for something that parses URLs in Ruby and Ruby on Rails and closely conforms to RFC 3986, RFC 3987, and RFC 6570 (level 4),
check out [addressable](https://github.com/sporkmonger/addressable).
If you need to do domain name validation check out [public_suffix](https://github.com/weppos/publicsuffix-ruby).

## Risks using this gem
The risk should be considered low. The gem is very small, simple and well-tested. The only risk is that it doesn't follow any RFCs. This means that it might not behave as you expect. However, it's very unlikely that you'll run into any problems.
The gem is maintained by [Qasa](https://www.qasa.se), we're a small team of dedicated Ruby developers.

## Contributing
Bug reports and pull requests are always welcome!

## License
See [LICENSE](LICENSE).
