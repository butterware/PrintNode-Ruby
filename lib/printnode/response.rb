module PrintNode
  # A lightweight value object returned by all API calls.
  # Provides dot-notation access to response fields. Raises NoMethodError
  # for fields not present in the response, unlike OpenStruct which returns nil.
  class Response
    def initialize(hash)
      @data = hash.transform_values { |v| self.class.wrap(v) }
    end

    # Recursively wraps a value: Hashes become Response objects,
    # Arrays are mapped over, scalars are returned as-is.
    def self.wrap(value)
      case value
      when Hash  then new(value)
      when Array then value.map { |v| wrap(v) }
      else            value
      end
    end

    def method_missing(name, *args)
      key = name.to_s
      raise NoMethodError, "undefined method '#{name}' for #{inspect}" unless @data.key?(key)
      @data[key]
    end

    def respond_to_missing?(name, include_private = false)
      @data.key?(name.to_s) || super
    end

    def ==(other)
      other.is_a?(self.class) && @data == other.instance_variable_get(:@data)
    end

    def inspect
      "#<PrintNode::Response #{@data.inspect}>"
    end
  end
end
