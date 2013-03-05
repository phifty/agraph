require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "allegro_graph"))

describe "server" do

  use_real_transport!

  before :each do
    @server = AllegroGraph::Server.new :username => ENV['AG_USER'], :password => ENV['AG_PASS']
  end

  it "should return the server's version" do
    @server.version.should have_key(:version)
  end

end
