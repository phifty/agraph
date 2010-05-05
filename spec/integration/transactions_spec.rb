require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "allegro_graph"))

describe "transactions" do

  use_real_transport!

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @repository = AllegroGraph::Repository.new @server, "test_repository"
    @repository.statements.delete
  end

  it "should commit all changes at once" do
    @repository.transaction do
      statements.create "\"test_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"test_object\""
      statements.create "\"another_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"another_object\""
    end

    result = @repository.statements.find
    result.should include([ "\"test_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"test_object\"" ])
    result.should include([ "\"another_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"another_object\"" ])
  end

  it "should rollback on error" do
    lambda do
      @repository.transaction do
        statements.create "\"test_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"test_object\""
        statements.create "\"another_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"another_object\""
        invalid
      end
    end.should raise_error(NameError)

    result = @repository.statements.find
    result.should_not include([ "\"test_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"test_object\"" ])
    result.should_not include([ "\"another_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"another_object\"" ])
  end

end
