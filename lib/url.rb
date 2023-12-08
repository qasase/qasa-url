# frozen_string_literal: true

require "rack/utils"

class URL
  HTTPS = "https"

  SEPARTOR = "://"
  private_constant :SEPARTOR

  SLASH = "/"
  private_constant :SLASH

  NOTHING = ""
  private_constant :NOTHING

  PORT_SEPARATOR = ":"
  private_constant :PORT_SEPARATOR

  QUERY_STRING_SEPARATOR = "?"
  private_constant :QUERY_STRING_SEPARATOR

  attr_accessor :domain, :port, :query
  attr_writer :protocol
  attr_reader :path

  class << self
    def parse(string)
      string
        .to_str
        .dup
        .then { extract_protocol(_1) }
        .then { extract_domain_and_port(*_1) }
        .then { extract_path_and_query(**_1) }
        .then do
          next nil if _1.compact.empty?

          new(**_1)
        end
    end
    alias_method :[], :parse

    private

    def extract_protocol(string)
      if string.include?(SEPARTOR)
        string.split(SEPARTOR)
      else
        [nil, string]
      end
    end

    def extract_domain_and_port(protocol, rest)
      return {} if rest.nil? || rest.empty?

      domain, port = rest.split("/")[0].split("?")[0].split(":")

      {protocol: protocol, domain: domain, port: port, rest: rest}
    end

    def extract_path_and_query(protocol: nil, domain: nil, port: nil, rest: nil)
      return {} if rest.nil?

      path, query =
        if rest.index("/")
          rest[rest.index("/")..].split("?")
        else
          [nil, rest.split("?")[1]]
        end

      {protocol: protocol, domain: domain, port: port, path: path, query: query}
    end
  end

  private_class_method :new
  def initialize(domain:, path: nil, protocol: nil, port: nil, query: nil)
    @protocol = protocol
    @domain = domain
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
    self.query = self.query.merge(query.transform_keys(&:to_s))

    self
  end

  def protocol
    @protocol || HTTPS
  end

  def to_str
    [
      protocol,
      SEPARTOR,
      domain,
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
end
