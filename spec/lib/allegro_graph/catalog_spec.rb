require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "allegro_graph", "catalog"))

describe AllegroGraph::Catalog do

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
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

  describe "path" do

    context "for root catalog" do

      before :each do
        @catalog.stub!(:root?).and_return(true)
      end

      it "should the root catalog url" do
        @catalog.path.should == ""
      end

    end

    context "for named catalog" do

      it "should the named catalog url" do
        @catalog.path.should == "/catalogs/test_catalog"
      end

    end

  end

  describe "exists?" do

    context "for a catalog that already exists" do

      it "should return true" do
        @catalog.exists?.should be_true
      end

    end

    context "for a catalog that not exists" do

      before :each do
        @catalog.name = "not_existing"
      end

      it "should return false" do
        @catalog.exists?.should be_false
      end

    end

  end

  describe "repositories" do

    before :each do
      @repository = AllegroGraph::Repository.new @catalog, "test_repository"
    end

    it "should return the catalog's repositories" do
      @catalog.repositories.should == [ @repository ]
    end
    
  end

end
