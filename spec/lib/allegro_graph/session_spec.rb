require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "allegro_graph", "session"))

describe AllegroGraph::Session do

  before :each do
    fake_transport!
    @session = AllegroGraph::Session.new :url => "http://session:5555", :username => "test", :password => "test"
  end

  describe "request_http" do

    before :each do
      Transport::HTTP.stub(:request)
    end

    it "should perform a http request" do
      Transport::HTTP.should_receive(:request).with(
        :get, "http://session:5555/", hash_including(:expected_status_code => 200)
      ).and_return("test" => "test")
      @session.request_http(:get, "/", :expected_status_code => 200).should == { "test" => "test" }
    end

  end

  describe "request_json" do

    before :each do
      Transport::JSON.stub(:request)
    end

    it "should perform a json request" do
      Transport::JSON.should_receive(:request).with(
        :get, "http://session:5555/", hash_including(:expected_status_code => 200)
      ).and_return("test" => "test")
      @session.request_json(:get, "/", :expected_status_code => 200).should == { "test" => "test" }
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

  describe "size" do

    it "should return the number of statements" do
      @session.size.should == 6
    end

  end

  describe "create" do

    before :each do
      @server = mock AllegroGraph::Server,
        :username => "test",
        :password => "test",
        :path => ""
      @server.stub(:server).and_return(@server)
      @repository = mock AllegroGraph::Repository,
        :path => "/repositories/test_repository",
        :request_http => "http://session:5555",
        :server => @server
    end

    it "should request a session on a store using the repository" do
      @repository.should_receive(:request_http).with(
        :post, "/repositories/test_repository/session", { :expected_status_code => 200, :parameters => { :autoCommit => true } }
      ).and_return("http://session:5555")
      AllegroGraph::Session.create @repository, :autoCommit => true
    end

    it "should request a session on a store using the server" do
      @server.should_receive(:request_http).with(
        :post, "/session", { :expected_status_code => 200, :parameters => { :store => '<store_x>' } }
      ).and_return("http://session:5555")
      AllegroGraph::Session.create @server, :store => 'store_x'
    end

    it "should request a session on a federated store" do
      @server.should_receive(:request_http).with(
        :post, "/session", { :expected_status_code => 200, :parameters => { :store => '<store_x>+<store_y>' } }
      ).and_return("http://session:5555")
      AllegroGraph::Session.create @server, :store => ['store_x', 'store_y']
    end

    it "should raise an error if no store is supplied" do
      lambda do
        AllegroGraph::Session.create @server
      end.should raise_error(ArgumentError)
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
