require 'uri'
require 'net/http'
require 'base64'
require 'json'

module AllegroGraph

  # Common transport layer for http transfers.
  module Transport

    # The UnexpectedStatusCodeError is raised if the :expected_status_code option is given to
    # the :request method and the responded status code is different from the expected one.
    class UnexpectedStatusCodeError < StandardError

      attr_reader :status_code

      def initialize(status_code)
        @status_code = status_code
      end

      def to_s
        "#{super} received status code #{self.status_code}"
      end

    end

    def self.request(http_method, url, options = { })
      expected_status_code = options[:expected_status_code]

      uri = URI.parse url
      response = perform request_object(http_method, uri, options), uri

      check_status_code response, expected_status_code if expected_status_code
      response.body
    end

    def self.request_object(http_method, uri, options)
      request_class_name = http_method.capitalize
      raise NotImplementedError, "the request method #{http_method} is not implemented" unless Net::HTTP.const_defined?(request_class_name)

      request_class = Net::HTTP.const_get request_class_name
      request_object = request_class.new uri.path + serialize_parameters(options[:parameters]), (options[:headers] || { })
      request_object.body = options[:body].to_json if options.has_key?(:body)
      request_object
    end

    def self.serialize_parameters(parameters)
      return "" if parameters.nil? || parameters.empty?
      "?" + parameters.collect do |key, value|
        "#{key}=#{URI.escape(serialize_parameter_value(value))}"
      end.reverse.join("&")
    end

    def self.serialize_parameter_value(value)
      value.to_s
    end

    def self.perform(request, uri)
      Net::HTTP.start(uri.host, uri.port) do |connection|
        connection.request request
      end
    end

    def self.check_status_code(response, expected_status_code)
      response_code = response.code
      raise UnexpectedStatusCodeError, response_code.to_i if expected_status_code.to_s != response_code
    end

  end

  module AuthorizedTransport

    def self.request(http_method, url, options = { })
      if options[:auth_type] == :basic
        options[:headers] ||= { }
        options[:headers]["Authorization"] = "Basic " + Base64.encode64("#{options[:username]}:#{options[:password]}")
      end
      Transport.request http_method, url, options
    end
    
  end

  # Common json transport layer for http transfers.
  module JSONTransport

    def self.request(http_method, url, options = { })
      options[:headers] ||= { }
      options[:headers]["Content-Type"] = "application/json"
      parse AuthorizedTransport.request(http_method, url, options)
    end

    def self.serialize_parameter_value(value)
      value.respond_to?(:to_json) ? value.to_json : AuthorizedTransport.serialize_parameter_value(value)
    end

    def self.parse(response)
      return nil if response.nil? || response == ""
      JSON.parse response
    end

  end

end
