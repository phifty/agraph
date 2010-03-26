require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "allegro_graph", "server"))

describe AllegroGraph::Server do

  before :each do
    FakeTransport.fake!
    @server = AllegroGraph::Server.new
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

  describe "version" do

    it "should return the server's version" do
      @server.version.should == {
        :version  => "4.0.1a",
        :date     => "March 10, 2010 10:23:52 GMT-0800",
        :revision => "[unknown]"
      }
    end

  end

end
