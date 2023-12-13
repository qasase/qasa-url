# frozen_string_literal: true

require "rack/utils"

class URL
  DOT = "."
  HTTPS = "https"

  SEPARATOR = "://"
  private_constant :SEPARATOR

  SLASH = "/"
  private_constant :SLASH

  NOTHING = ""
  private_constant :NOTHING

  PORT_SEPARATOR = ":"
  private_constant :PORT_SEPARATOR

  QUERY_STRING_SEPARATOR = "?"
  private_constant :QUERY_STRING_SEPARATOR

  attr_accessor :host, :port, :query
  attr_writer :protocol
  attr_reader :path

  class << self
    def parse(string)
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
    alias_method :[], :parse

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

  def join(*paths)
    paths.map do |path|
      path.start_with?(SLASH) ? path.sub(SLASH, NOTHING) : path.dup
    end.then do |paths|
      self.path = Array(path).concat(paths).join(SLASH)
    end

    self
  end

  def merge(query)
    self.query = self.query.merge(deep_transform_keys(query))

    self
  end

  def protocol
    @protocol || HTTPS
  end

  def tld
    domain_parts.last
  end

  def sld
    domain_parts.then do |parts|
      next if parts.size < 2

      parts[-2]
    end
  end

  def domain
    [sld, tld].compact.join(DOT)
  end

  def subdomain
    (domain_parts - [sld, tld].compact).then do |parts|
      next if parts.empty?

      parts.join(DOT)
    end
  end

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

  def inspect
    super.split(" ")[0].concat(" #{to_str}>")
  end

  private

  def query_params
    if query.any?
      QUERY_STRING_SEPARATOR.dup.concat(Rack::Utils.build_nested_query(query))
    else
      NOTHING
    end
  end

  def port_str
    if port
      PORT_SEPARATOR.dup.concat(port.to_s)
    else
      NOTHING
    end
  end

  def path_str
    Rack::Utils.escape_path(path) if path && !path.empty?
  end

  def deep_transform_keys(hash)
    hash.each_with_object({}) do |(key, value), result|
      result[key.to_s] =
        value.is_a?(Hash) ? deep_transform_keys(value) : value
    end
  end

  def domain_parts
    host.split(DOT)
  end
end
