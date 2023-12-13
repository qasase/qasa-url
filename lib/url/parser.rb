class URL
  class Parser
    class << self
      def parse(string)
        string
          .to_str
          .dup
          .then { extract_protocol(_1) }
          .then { extract_host_and_port(*_1) }
          .then { extract_path_and_query(**_1) }
      end

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
  end
end
