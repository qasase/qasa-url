# frozen_string_literal: true

require "rack/utils"

class URL
  Error = Class.new(StandardError)

  DOT = "."
  HTTP = "http"
  HTTPS = "https"
  NOTHING = ""
  PORT_SEPARATOR = ":"
  QUERY_STRING_SEPARATOR = "?"
  SEPARATOR = "://"
  SLASH = "/"
  SPACE = " "

  # @private
  ERROR_MESSAGES = {
    "tld=": {
      missing_tld: "Cannot change top level domain (TLD) on a host initialized without a TLD (%{url})"
    },
    "subdomain=": {
      missing_tld: "Cannot set subdomain on a host with only a second level domain (SLD) (%{url})"
    }
  }
  private_constant :ERROR_MESSAGES

  # @!attribute [rw] host
  #   @return [String]
  #   @param [String]
  attr_accessor :host

  # @!attribute [rw] port
  #   @param [String]
  attr_accessor :port

  # @!attribute [rw] query
  #   @return [Hash]
  attr_accessor :query

  # @!attribute [w] protocol
  #   @param [String]
  attr_writer :protocol

  # @!method scheme=
  #   @see #protocol=
  alias_method :scheme=, :protocol=

  # @!attribute [r] path
  #   @return [String]
  attr_reader :path

  class << self
    # Initializes a new URL object from a given string
    # @param [String] the URL to parse
    # @return [URL] A new URL object
    # @example
    #   URL.parse("https://www.example.com:3000/path?query=string")
    #   # => #<URL:0x00007f9b9c0b3b20 https://www.example.com:3000/path?query=string>
    def parse(string)
      return nil if string.nil?

      string
        .to_str
        .dup
        .then { extract_protocol(_1) }
        .then { extract_host_and_port(*_1) }
        .then { extract_path_and_query(**_1) }
        .then do
          next nil if _1.compact.empty?

          new(**_1)
        end
    end

    # @!method []
    #   @see #parse
    alias_method :[], :parse

    # @!visibility private
    private

    def extract_protocol(string)
      if string.include?(SEPARATOR)
        string.split(SEPARATOR)
      else
        [nil, string]
      end
    end

    def extract_host_and_port(protocol, rest)
      return {} if rest.nil? || rest.empty?

      host, port = rest.split("/")[0].split("?")[0].split(":")

      {protocol: protocol, host: host, port: port, rest: rest}
    end

    def extract_path_and_query(protocol: nil, host: nil, port: nil, rest: nil)
      return {} if rest.nil?

      path, query =
        if rest.index("/")
          rest[rest.index("/")..].split("?")
        else
          [nil, rest.split("?")[1]]
        end

      {protocol: protocol, host: host, port: port, path: path, query: query}
    end
  end

  private_class_method :new

  # @private
  def initialize(host:, path: nil, protocol: nil, port: nil, query: nil)
    @protocol = protocol
    @host = host
    @port = port&.to_i
    self.path = path
    @query = Rack::Utils.parse_nested_query(query)
  end

  def path=(path)
    @path =
      if path.nil?
        nil
      elsif path.start_with?(SLASH)
        path.dup
      else
        SLASH.dup.concat(path)
      end
  end

  # Adds a path to the URL
  # @overload join(path)
  #   @param path [String] a single string path
  # @overload join(*paths)
  #   @param paths [Array<String>] an array of string paths
  # @return [URL] self
  # @example
  #   url = URL.parse("https://www.example.com")
  #   url.join("path").path("to", "nowhere")
  #   url.to_s # => "https://www.example.com/path/to/nowhere"
  # @example
  #  url = URL.parse("https://www.example.com/")
  #  url.join("/path", "/to/", "nowhere/")
  #  url.to_s # => "https://www.example.com/path/to/nowhere/"
  def join(*paths)
    parts = Array(path).concat(paths)
    size = parts.size

    parts
      .map
      .with_index(1) { |part, index| sanitize_path(part, last: index == size) }
      .compact
      .then do |parts|
        self.path = Array(NOTHING).concat(parts).join(SLASH)
      end

    self
  end

  # Append query parameters to the URL
  # @param [Hash]
  # @return [URL] self
  # @example
  #   url = URL.parse("https://www.example.com")
  #   url.merge(query: "string")
  #   url.to_s # => "https://www.example.com?query=string"
  def merge(query)
    self.query = self.query.merge(deep_transform_keys(query))

    self
  end

  # @return [String, HTTPS] the protocol, defaults to "https"
  def protocol
    @protocol || HTTPS
  end
  alias_method :scheme, :protocol

  # Sets the top level domain (TLD)
  # @param [String]
  # @raise [URL::Error] if the host was initialized without a top level domain (TLD)
  def tld=(new_tld)
    domain_parts.tap do |parts|
      raise(Error, ERROR_MESSAGES[:tld=][:missing_tld] % {url: to_s}) if tld.nil?

      @host = [subdomain, sld, new_tld].compact.join(DOT)
    end
  end

  # Returns the top level domain (TLD)
  # @return [String, nil]
  def tld
    domain_parts.last if domain_parts.size > 1
  end

  # Sets the second level domain (SLD)
  # @param [String]
  # @raise [URL::Error] if the host was initialized without a top level domain (TLD)
  def sld=(new_sld)
    domain_parts.tap do |parts|
      @host = [subdomain, new_sld, tld].compact.join(DOT)
    end
  end

  # @return [String, nil] the second level domain (SLD)
  def sld
    domain_parts.then do |parts|
      if parts.size < 2
        parts.last
      else
        parts[-2]
      end
    end
  end

  # Returns the domain name
  # @return [String]
  # @example
  #   url = URL.parse("https://www.example.com")
  #   url.domain # => "example.com"
  def domain
    [sld, tld].compact.join(DOT)
  end

  # @param [String]
  # @return [String]
  # @raise [URL::Error] if the host was initialized without a top level domain (TLD)
  def subdomain=(new_subdomain)
    domain_parts.tap do |parts|
      raise(Error, ERROR_MESSAGES[:subdomain=][:missing_tld] % {url: to_s}) if tld.nil?

      @host = [new_subdomain, sld, tld].join(DOT)
    end
  end

  # Returns the subdomain
  # @return [String, nil]
  def subdomain
    (domain_parts - [sld, tld].compact).then do |parts|
      next if parts.empty?

      parts.join(DOT)
    end
  end

  # Returns the full URL as a string
  # @return [String]
  def to_str
    [
      protocol,
      SEPARATOR,
      host,
      port_str,
      path_str,
      query_params
    ].compact.join
  end
  alias_method :to_s, :to_str

  # @private
  def inspect
    super.split(" ")[0].concat(" #{to_str}>")
    super.split(SPACE)[0].concat(" #{to_str}>")
  end

  private

  # @private
  def query_params
    if query.any?
      QUERY_STRING_SEPARATOR.dup.concat(Rack::Utils.build_nested_query(query))
    else
      NOTHING
    end
  end

  # @private
  def port_str
    if port
      PORT_SEPARATOR.dup.concat(port.to_s)
    else
      NOTHING
    end
  end

  # @private
  def path_str
    Rack::Utils.escape_path(path) if path && !path.empty?
  end

  # @private
  def deep_transform_keys(hash)
    hash.each_with_object({}) do |(key, value), result|
      result[key.to_s] =
        value.is_a?(Hash) ? deep_transform_keys(value) : value
    end
  end

  def domain_parts
    host.split(DOT)
  end

  def sanitize_path(path, last:)
    path = path.start_with?(SLASH) ? path[1..] : path.dup
    path = path.end_with?(SLASH) ? path[..-2] : path unless last

    path.empty? ? nil : path
  end
end
