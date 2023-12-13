# frozen_string_literal: true

require "forwardable"

require "rack/utils"

require_relative "url/host"
require_relative "url/parser"
require_relative "url/stringify"

class URL
  extend Forwardable

  DOT = "."
  HTTPS = "https"
  NOTHING = ""
  PORT_SEPARATOR = ":"
  QUERY_STRING_SEPARATOR = "?"
  SEPARATOR = "://"
  SLASH = "/"
  SPACE = " "

  class << self
    def parse(string)
      Parser
        .parse(string)
        .then do
          next if _1.compact.empty?

          new(**_1)
        end
    end
    alias_method :[], :parse
  end

  attr_accessor :port, :query
  attr_writer :protocol
  attr_reader :host, :path

  alias_method :scheme=, :protocol=

  def_delegators :host, :domain, :sld, :subdomain, :tld

  private_class_method :new
  def initialize(host:, path: nil, protocol: nil, port: nil, query: nil)
    @protocol = protocol
    self.host = host
    @port = port&.to_i
    self.path = path
    @query = Rack::Utils.parse_nested_query(query)
  end

  def host=(string)
    @host = Host.new(string)
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
  alias_method :scheme, :protocol

  def to_str
    Stringify.to_str(self)
  end
  alias_method :to_s, :to_str

  def inspect
    super.split(SPACE)[0].concat(" #{to_str}>")
  end

  private

  def deep_transform_keys(hash)
    hash.each_with_object({}) do |(key, value), result|
      result[key.to_s] =
        value.is_a?(Hash) ? deep_transform_keys(value) : value
    end
  end
end
