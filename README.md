# URL

URL is a simple URL parser and construction tool for Ruby. It doesn't follow any RFC, instead, it behaves as you expect.

## Background
I wrote this after being frustrated with the URL handling in Ruby's standard library and other gems. I wanted to be able to parse a URL, modify it and then get the modified URL back as a string. I also wanted to be able to join paths and query strings to URLs without having to worry about trailing slashes and question marks.

## Installation
Just point to this repository in your Gemfile:
```ruby
gem "url", "0.0.0.rc1", require: "url",  github: "ingemar/url", tag: "v0.0.0.rc1"
```

## Usage
Initialize a new URL object by parsing a URL string or domain name:
```ruby
require "url"

url = URL.parse("http://www.example.com/path")
url.to_s # => "http://www.example.com:404/path"
url.join("/to")
url.join("/nowhere")
url.to_s # => "http://www.example.com:404/path/to/nowhere"
url.merge(foo: "bar")
url.to_s # => "http://www.example.com:404/path/to/nowhere?foo=bar"
```

## Contributing

Bug reports and pull requests are always welcome!
