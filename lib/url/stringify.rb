class URL
  class Stringify
    class << self
      def to_str(...)
        new(...).to_str
      end
    end

    def initialize(url)
      @url = url
    end

    def to_str
      [
        protocol,
        URL::SEPARATOR,
        host,
        port_str,
        path_str,
        query_params
      ].compact.join
    end

    def respond_to_missing?(method, include_private = false)
      url.respond_to?(method, include_private)
    end

    private

    attr_reader :url

    def method_missing(method, ...)
      if url.respond_to?(method)
        url.send(method, ...)
      else
        super
      end
    end

    def query_params
      if query.any?
        URL::QUERY_STRING_SEPARATOR.dup.concat(Rack::Utils.build_nested_query(query))
      else
        URL::NOTHING
      end
    end

    def port_str
      if port
        URL::PORT_SEPARATOR.dup.concat(port.to_s)
      else
        URL::NOTHING
      end
    end

    def path_str
      Rack::Utils.escape_path(path) if path && !path.empty?
    end
  end
end
