require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "allegro_graph", "session"))

describe AllegroGraph::Session do

  before :each do
    @session = AllegroGraph::Session.new :url => "http://session:5555", :username => "test", :password => "test"
  end

  describe "request" do

    before :each do
      AllegroGraph::ExtendedTransport.stub!(:request)
    end

    it "should perform an extended request" do
      AllegroGraph::ExtendedTransport.should_receive(:request).with(
        :get, "http://session:5555/", hash_including(:expected_status_code => 200)
      ).and_return("test" => "test")
      @session.request(:get, "/", :expected_status_code => 200).should == { "test" => "test" }
    end

  end

  describe "commit" do

    it "should return true" do
      result = @session.commit
      result.should be_true
    end

  end

  describe "rollback" do

    it "should return true" do
      result = @session.rollback
      result.should be_true
    end

  end

  describe "create" do

    before :each do
      @server = Object.new
      @server.stub!(:username).and_return("test")
      @server.stub!(:password).and_return("test")
      @repository = Object.new
      @repository.stub!(:path).and_return("/repositories/test_repository")
      @repository.stub!(:request).and_return("http://session:5555")
      @repository.stub!(:server).and_return(@server)
    end

    it "should request a session" do
      @repository.should_receive(:request).with(
        :post, "/repositories/test_repository/session", :expected_status_code => 200
      ).and_return("http://session:5555")
      AllegroGraph::Session.create @repository
    end

    it "should return a session" do
      result = AllegroGraph::Session.create @repository
      result.should be_instance_of(AllegroGraph::Session)
    end

    it "should set the correct values" do
      result = AllegroGraph::Session.create @repository
      result.url.should == "http://session:5555"
      result.username.should == "test"
      result.password.should == "test"
    end

  end

end
