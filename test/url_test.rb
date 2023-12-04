require "test_helper"

class URLTest < Minitest::Test
  describe ".parse" do
    it "parses a URL" do
      result = URL.parse("http://www.example.com:404/path/to/nowhere?query=string")

      assert_equal "http", result.protocol
      assert_equal "www.example.com", result.domain
      assert_equal 404, result.port
      assert_equal "/path/to/nowhere", result.path
      assert_equal(
        {"query" => "string"},
        result.query
      )
    end

    it "parses a URL without protocol" do
      result = URL.parse("example.com")

      assert_equal "https", result.protocol
      assert_equal "example.com", result.domain
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

    it "returns self" do
      url = URL.parse("http://www.example.com")

      result = url.merge("query" => "string")

      assert_equal url, result
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
