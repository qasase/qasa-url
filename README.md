# URL

URL is a simple URL parser and construction tool for Ruby. It doesn't follow any RFC, instead, it behaves as you expect.

## Background
I wrote this after being frustrated with the URL handling in Ruby's standard library and other gems. I wanted to be able to parse a URL, modify it and then get the modified URL back as a string. I also wanted to be able to join paths and query strings to URLs without having to worry about trailing slashes and question marks.

## Installation
Just point to this repository in your Gemfile:
```ruby
gem "url", "0.0.0.rc1" github: "ingemar/url", tag: "v0.0.0.rc1"
```

## Usage
Initialize a new URL object by parsing a URL string or domain name:
```ruby
url = URL.parse("http://www.example.com:404/path")
url.to_s # => "http://www.example.com:404/path"
url.port = nil
url.join("/to")
url.join("/nowhere")
url.to_s # => "http://www.example.com/path/to/nowhere"
url.merge(foo: "bar")
url.to_s # => "http://www.example.com/path/to/nowhere?foo=bar"
```

## Advanced usage
Only use these features if you're a seasoned professional.
```ruby
# Ugly "syntactic sugar" is supported because this is not opinionated code ;pPppPpPPPpp
url = URL["example.com"]
# Join as much as you want for the price of one!
url.join("/path", "to", "nowhere")
# Not providing a protocol will default to 'https'. This code is contemporary.
url.to_s # => "https://example.com/path/to/nowhere"
```

## Alternaives
If you're looking for something that parses URLs in Ruby and Ruby on Rails and behaves erratically but closely conforms to RFC 3986, RFC 3987, and RFC 6570 (level 4),
check out [addressable](https://github.com/sporkmonger/addressable). It's probably better tested and has industrywide adoption or something.

## Contributing
Bug reports and pull requests are always welcome!
