require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "allegro_graph"))

describe AllegroGraph::Catalog do

  use_real_transport!

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @catalog = AllegroGraph::Catalog.new @server, "test_catalog"
  end

  describe "create!" do

    it "should raise a StandardError on root catalog" do
      @catalog.stub!(:root?).and_return(true)
      lambda do
        @catalog.create!
      end.should raise_error(StandardError)
    end

    it "should create the catalog" do
      # @catalog.create!.should be_true
    end

  end

  describe "exists?" do

    it "should return false if not existing" do
      #@catalog.exists?.should be_false
    end

    it "should return true if existing" do
      #@catalog.create!
      #@catalog.exists?.should be_true
    end

  end

  describe "repositories" do

    

  end

end
