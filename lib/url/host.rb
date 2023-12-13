# frozen_string_literal: true

class URL
  class Host < String
    DOT = "."

    def tld
      parts.last
    end

    def sld
      parts.then do |parts|
        next if parts.size < 2

        parts[-2]
      end
    end

    def domain
      [sld, tld].compact.join(DOT)
    end

    def subdomain
      (parts - [sld, tld].compact).then do |parts|
        next if parts.empty?

        parts.join(DOT)
      end
    end

    private

    def parts
      split(DOT)
    end
  end
end
