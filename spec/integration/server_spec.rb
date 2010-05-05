require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "allegro_graph"))

describe "server" do

  use_real_transport!

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
  end

  it "should return the server's version" do
    @server.version.should == {
      :version  => "\"4.0.1a\"",
      :date     => "\"March 10, 2010 10:23:52 GMT-0800\"",
      :revision => "\"[unknown]\""
    }
  end

end
