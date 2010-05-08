
module AllegroGraph

  # The Resource class acts as a base for statement resources. It provide proxy classes that provide methods
  # to manipulate that statements.
  class Resource

    attr_reader :statements
    attr_reader :query
    attr_reader :geometric
    attr_reader :mapping

    def initialize(*arguments)
      @statements = Proxy::Statements.new self
      @query      = Proxy::Query.new self
      @geometric  = Proxy::Geometric.new self
      @mapping    = Proxy::Mapping.new self
    end

  end

end