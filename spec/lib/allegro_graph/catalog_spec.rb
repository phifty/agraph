require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "allegro_graph", "catalog"))

describe AllegroGraph::Catalog do

  before :each do
    @server = AllegroGraph::Server.new
    @catalog = AllegroGraph::Catalog.new @server, "test_catalog"
  end

  describe "==" do

    it "should be true when comparing two equal catalogs" do
      other = AllegroGraph::Catalog.new @server, "test_catalog"
      @catalog.should == other
    end

    it "should be false when comparing two different catalog" do
      other = AllegroGraph::Catalog.new @server, "other_catalog"
      @catalog.should_not == other
    end

  end

  describe "url" do

    context "for root catalog" do

      before :each do
        @catalog.stub!(:root?).and_return(true)
      end

      it "should the root catalog url" do
        @catalog.url.should == "#{@server.url}"
      end

    end

    context "for named catalog" do

      it "should the named catalog url" do
        @catalog.url.should == "#{@server.url}/catalogs/test_catalog"
      end

    end

  end

  describe "repositories" do

    it "should return the catalog's repositories" do
      @catalog.repositories.should == [ ]
    end

  end

end
