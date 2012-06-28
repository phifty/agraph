
module AllegroGraph

  # The Repository class wrap the corresponding resource on the AllegroGraph server. A repository acts as a scope for
  # statements. Simple management methods are provided.
  class Repository < Resource

    attr_reader   :server
    attr_reader   :catalog
    attr_accessor :name

    def initialize(server_or_catalog, name)
      super
      @catalog  = server_or_catalog.is_a?(AllegroGraph::Server) ? server_or_catalog.root_catalog : server_or_catalog
      @server   = @catalog.server
      @name     = name
    end

    def ==(other)
      other.is_a?(self.class) && self.catalog == other.catalog && self.name == other.name
    end

    def path
      "#{@catalog.path}/repositories/#{@name}"
    end

    def request_http(*arguments)
      @server.request_http *arguments
    end

    def request_json(*arguments)
      @server.request_json *arguments
    end

    def exists?
      @catalog.repositories.include? self
    end

    def create!
      @server.request_http :put, self.path, :expected_status_code => 204
      true
    rescue ::Transport::UnexpectedStatusCodeError => error
      return false if error.status_code == 400
      raise error
    end

    def create_if_missing!
      create! unless exists?
    end

    def delete!
      @server.request_http :delete, self.path, :expected_status_code => 200
      true
    rescue ::Transport::UnexpectedStatusCodeError => error
      return false if error.status_code == 400
      raise error
    end

    def delete_if_exists!
      delete! if exists?
    end

    def size
      response = @server.request_http :get, self.path + "/size", :type => :text, :expected_status_code => 200
      response.to_i
    end

    def remove_duplicates(mode=:spog)
      response = @server.request_http :delete, self.path + "/statements/duplicates", :parameters => {:mode => mode.to_s}, :expected_status_code => 200
      response.to_i
    end

    def suppress_duplicates=(type=:spog)
      response = @server.request_http :put, self.path + "/suppressDuplicates", :parameters => {:type => type.to_s}, :expected_status_code => 204
      true
    end

    def suppress_duplicates
      strategy = @server.request_http :get, self.path + "/suppressDuplicates", :expected_status_code => 200
      strategy == 'false' ? false : strategy.to_sym
    end

    def optimize(parameters={})
      parameters = { :wait => 'false', :level => '1' }.merge(parameters)
      response = @server.request_http :post, self.path + "/indices/optimize", :parameters => parameters, :expected_status_code => 204
      response == 'nil'
    end

    def transaction(options={}, &block)
      self.class.transaction self, options, &block
    end

    def self.transaction(repository, options={}, &block)
      session = Session.create repository, options
      begin
        session.instance_eval &block
      rescue Object => error
        session.rollback
        raise error
      end
      session.commit
    end

  end

end
