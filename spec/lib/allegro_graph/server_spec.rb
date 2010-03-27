require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "allegro_graph", "server"))

describe AllegroGraph::Server do

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
  end

  describe "==" do

    it "should be true when comparing two equal servers" do
      other = AllegroGraph::Server.new
      @server.should == other
    end

    it "should be false when comparing two different servers" do
      other = AllegroGraph::Server.new :host => "other"
      @server.should_not == other
    end
    
  end

  describe "request" do

    before :each do
      AllegroGraph::JSONTransport.stub!(:request)
    end

    it "should perform a authorized json request on default" do
      AllegroGraph::JSONTransport.should_receive(:request).with(
        :get, "http://localhost:10035/", hash_including(:expected_status_code => 200)
      ).and_return("test" => "test")
      @server.request(:get, "/", :expected_status_code => 200).should == { "test" => "test" }
    end

    it "should perform a authorized text request if requested" do
      AllegroGraph::AuthorizedTransport.should_receive(:request).with(
        :get, "http://localhost:10035/", hash_including(:expected_status_code => 200)
      ).and_return("test" => "test")
      @server.request(:get, "/", :expected_status_code => 200, :type => :text).should == { "test" => "test" }
    end

  end

  describe "version" do

    it "should return the server's version" do
      @server.version.should == {
        :version  => "4.0.1a",
        :date     => "March 10, 2010 10:23:52 GMT-0800",
        :revision => "[unknown]"
      }
    end

  end

  describe "catalogs" do

    before :each do
      @catalog = AllegroGraph::Catalog.new @server, "test_catalog"
    end

    it "should return the catalogs of the server" do
      @server.catalogs.should == [ @server.root_catalog, @catalog ]
    end

  end

end
