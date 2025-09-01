require "test_helper"

class URLTest < Minitest::Test
  describe ".parse" do
    it "parses a URL" do
      result = URL.parse("http://www.example.com:404/path/to/nowhere?query=string")

      assert_equal "http", result.protocol
      assert_equal "www.example.com", result.host
      assert_equal 404, result.port
      assert_equal "/path/to/nowhere", result.path
      assert_equal(
        {"query" => "string"},
        result.query
      )
    end

    it "parses a url with protocol in path" do
      result = URL.parse("https://img.example.com/images/200x200/https://backend.example.com/img/abcd.jpg")

      assert_equal "https", result.protocol
      assert_equal "img.example.com", result.host
      assert_nil result.port
      assert_equal "/images/200x200/https://backend.example.com/img/abcd.jpg", result.path
      assert_equal({}, result.query)
    end

    it "parses a url with no protocol, but a protocol in path" do
      result = URL.parse("example.com:8888/files/ftp://ftp.example.com/file_123.zip")

      assert_equal "https", result.protocol
      assert_equal "example.com", result.host
      assert_equal 8888, result.port
      assert_equal "/files/ftp://ftp.example.com/file_123.zip", result.path
      assert_equal({}, result.query)
    end

    it "parses a URL with '+' in the protocol" do
      result = URL.parse("coap+ws://example.org/sensors/temperature?u=Cel")

      assert_equal "coap+ws", result.protocol
      assert_equal "example.org", result.host
      assert_nil result.port
      assert_equal "/sensors/temperature", result.path
      assert_equal({"u" => "Cel"}, result.query)
    end

    it "parses a URL with '.' in the protocol" do
      result = URL.parse("z39.50r://cnidr.org:2100/tmf?bkirch_rules__a1;esn=f;rs=marc")

      assert_equal "z39.50r", result.protocol
      assert_equal "cnidr.org", result.host
      assert_equal 2100, result.port
      assert_equal "/tmf", result.path
      assert_equal({"bkirch_rules__a1;esn" => "f;rs=marc"}, result.query)
    end

    it "parses a URL with '-' in the protocol" do
      result = URL.parse("ms-browser-extension://example.com")

      assert_equal "ms-browser-extension", result.protocol
      assert_equal "example.com", result.host
      assert_nil result.port
      assert_nil result.path
      assert_equal({}, result.query)
    end

    it "parses a URL with a number in the protocol" do
      result = URL.parse("s3://s3-us-west-2.amazonaws.com/s3test.example.com/dataset1/normal/config=/home/gpadmin/aws_s3/s3.conf")

      assert_equal "s3", result.protocol
      assert_equal "s3-us-west-2.amazonaws.com", result.host
      assert_nil result.port
      assert_equal "/s3test.example.com/dataset1/normal/config=/home/gpadmin/aws_s3/s3.conf", result.path
      assert_equal({}, result.query)
    end

    it "parses a URL without protocol" do
      result = URL.parse("example.com")

      assert_equal "https", result.protocol
      assert_equal "example.com", result.host
      assert_nil result.port
      assert_nil result.path
      assert_equal({}, result.query)
    end

    it "returns nil if given an empty string" do
      result = URL.parse("")

      assert_nil result
    end
  end

  describe "#join" do
    it "joins a path" do
      url = URL.parse("http://www.example.com")

      url.join("path")

      assert_equal "/path", url.path
    end

    it "does noth overwrite the initial path like Addressable::URI" do
      url = URL.parse("http://www.example.com/path")

      url.join("joined-path")

      assert_equal "/path/joined-path", url.path
    end

    it "can join multiple paths" do
      url = URL.parse("http://www.example.com")

      url.join("path", "to", "nowhere")

      assert_equal "/path/to/nowhere", url.path
    end

    it "joins paths with slashes" do
      url = URL.parse("http://www.example.com")

      url.join("/path", "/to", "/nowhere")

      assert_equal "/path/to/nowhere", url.path
    end

    it "returns self" do
      url = URL.parse("http://www.example.com")

      result = url.join("/pat")

      assert_equal url, result
    end
  end

  describe "#merge" do
    it "merges a query" do
      url = URL.parse("http://www.example.comi?foo=bar")

      url.merge("query" => "string")

      assert_equal(
        {"foo" => "bar", "query" => "string"},
        url.query
      )
    end

    it "merges a query with a symbol key" do
      url = URL.parse("http://www.example.comi?foo=bar")

      url.merge(foo: "baz", query: "string", deep: {key: "value"})

      assert_equal(
        {"foo" => "baz", "query" => "string", "deep" => {"key" => "value"}},
        url.query
      )
    end

    it "returns self" do
      url = URL.parse("http://www.example.com")

      result = url.merge("query" => "string")

      assert_equal url, result
    end
  end

  describe "#tld=" do
    it "sets the top level domain name (TLD)" do
      url = URL.parse("https://www.example.com")

      url.tld = "org"

      assert_equal "www.example.org", url.host
    end

    it "raises en error if there is no second level domain (SLD)" do
      url = URL.parse("http://example:3000")

      assert_raises URL::Error do
        url.tld = "com"
      end
    end
  end

  describe "#tld" do
    it "returns the top level domain name (TLD)" do
      url = URL.parse("https://www.example.com")

      result = url.tld

      assert_equal "com", result
    end

    it "returns nil if there is no TLD" do
      url = URL.parse("http://localhost:3000")

      result = url.tld

      assert_nil result
    end
  end

  describe "#sld=" do
    it "sets the second level domain name (SLD)" do
      url = URL.parse("https://www.example.com")

      url.sld = "test"

      assert_equal "www.test.com", url.host
    end

    it "can handle a domain without TLD" do
      url = URL.parse("http://localhost:3000")

      url.sld = "0.0.0.0"

      assert_equal "0.0.0.0", url.host
    end
  end

  describe "#sld" do
    it "returns the second level domain name (SLD)" do
      url = URL.parse("https://www.example.com")

      result = url.sld

      assert_equal "example", result
    end

    it "returns the SLD if there is not TLD" do
      url = URL.parse("http://localhost:3000")

      result = url.sld

      assert "localhost", result
    end
  end

  describe "#domain" do
    it "returns the domain name (SLD + TLD)" do
      url = URL.parse("https://www.example.com")

      result = url.domain

      assert_equal "example.com", result
    end

    it "can handle a domain without SLD" do
      url = URL.parse("http://localhost:3000")

      result = url.domain

      assert_equal "localhost", result
    end
  end

  describe "#subdomain=" do
    it "sets the subdomain" do
      url = URL.parse("https://go.deep.example.com")

      url.subdomain = "surface"

      assert_equal "surface.example.com", url.host
    end

    it "can handle a host without subdomain" do
      url = URL.parse("https://example.com")

      url.subdomain = "go.deep"

      assert_equal "go.deep.example.com", url.host
    end

    it "raises an error if the host has no TLD" do
      url = URL.parse("http://localhost:3000")

      assert_raises URL::Error do
        url.subdomain = "sub"
      end
    end
  end

  describe "#subdomain" do
    it "returns the subdomain" do
      url = URL.parse("https://plenty.subs.example.com")

      result = url.subdomain

      assert_equal "plenty.subs", result
    end

    it "returns nil if there is no subdomain" do
      url = URL.parse("https://example.com")

      result = url.subdomain

      assert_nil result
    end

    it "returns nil if there is no SLD" do
      url = URL.parse("http://localhost:3000")

      result = url.subdomain

      assert_nil result
    end
  end

  describe "#to_s" do
    it "returns a string representation of the URL" do
      url = URL.parse("http://www.example.com:404/path/to/nowhere?query=string")

      result = url.to_s

      assert_equal "http://www.example.com:404/path/to/nowhere?query=string", result
    end

    it "returns a string representation of the URL" do
      url = URL.parse("example.com")

      result = url.to_s

      assert_equal "https://example.com", result
    end
  end
end
