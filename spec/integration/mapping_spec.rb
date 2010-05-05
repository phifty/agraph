require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "allegro_graph"))

describe "mapping" do

  use_real_transport!

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @repository = AllegroGraph::Repository.new @server, "test_repository"    
    @repository.create_if_missing!
    @statements = @repository.statements
    @mapping = @repository.mapping
  end

  describe "creating a type" do

    it "should return true" do
      result = @mapping.create "<time>", "<http://www.w3.org/2001/XMLSchema#dateTime>"
      result.should be_true
    end

  end

  describe "creating a type" do

    before :each do
      @mapping.create "<time>", "<http://www.w3.org/2001/XMLSchema#dateTime>"
    end

    it "should return true" do
      result = @mapping.delete "<time>"
      result.should be_true
    end

  end

  describe "using a type for a range query" do

    before :each do
      @mapping.create "<time>", "<http://www.w3.org/2001/XMLSchema#dateTime>"
      @statements.create "\"event_one\"", "<happened>", "\"2010-03-29T17:00:00\"^^<time>"
      @statements.create "\"event_two\"", "<happened>", "\"2010-03-29T18:00:00\"^^<time>"
      @statements.create "\"event_three\"", "<happened>", "\"2010-03-29T19:00:00\"^^<time>"
    end

    it "should findthe statements for the given time" do
      result = @statements.find :predicate => "<happened>", :object => [ "\"2010-03-29T16:30:00\"^^<time>", "\"2010-03-29T18:30:00\"^^<time>" ]
      result.should include([ "\"event_one\"", "<happened>", "\"2010-03-29T17:00:00Z\"^^<http://www.w3.org/2001/XMLSchema#dateTime>" ])
      result.should include([ "\"event_two\"", "<happened>", "\"2010-03-29T18:00:00Z\"^^<http://www.w3.org/2001/XMLSchema#dateTime>" ])
      result.should_not include([ "\"event_three\"", "<happened>", "\"2010-03-29T19:00:00Z\"^^<http://www.w3.org/2001/XMLSchema#dateTime>" ])
    end

  end

end
