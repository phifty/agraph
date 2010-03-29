require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "allegro_graph", "federation"))

describe AllegroGraph::Federation do

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @federation = AllegroGraph::Federation.new @server,
                                               "test_federation",
                                               :repository_names  => [ "test_repository" ],
                                               :repository_urls   => [ "http://username:password@server:10035/repositories/another" ]
  end

  describe "==" do

    it "should be true when comparing two equal federations" do
      other = AllegroGraph::Federation.new @server, "test_federation"
      @federation.should == other
    end

    it "should be false when comparing two different federations" do
      other = AllegroGraph::Federation.new @server, "other_federationy"
      @federation.should_not == other
    end

  end

  describe "request" do

    before :each do
      @server.stub!(:request)
    end

    it "should call the server's request method" do
      @server.should_receive(:request).with(:get, "/", { })
      @federation.request :get, "/"
    end

  end

  describe "exists?" do

    context "for a federation that already exists" do

      it "should return true" do
        @federation.exists?.should be_true
      end

    end

    context "for a federation that not exists" do

      before :each do
        @federation.name = "not_existing"
      end

      it "should return false" do
        @federation.exists?.should be_false
      end

    end

  end

  describe "create!" do

    it "should return true" do
      @federation.create!.should be_true
    end

  end

  describe "create_if_missing!" do

    it "should do nothing if the federation already exists" do
      @federation.stub!(:exists?).and_return(true)
      @federation.should_not_receive(:create!)
      @federation.create_if_missing!
    end

    it "should call create! if the federation doesn't exists" do
      @federation.stub!(:exists?).and_return(false)
      @federation.should_receive(:create!)
      @federation.create_if_missing!
    end

  end

  describe "delete!" do

    it "should return true" do
      @federation.delete!.should be_true
    end

  end

  describe "delete_if_exists!" do

    it "should call delete! if the federation already exists" do
      @federation.stub!(:exists?).and_return(true)
      @federation.should_receive(:delete!)
      @federation.delete_if_exists!
    end

    it "should do nothing if the federation doesn't exists" do
      @federation.stub!(:exists?).and_return(false)
      @federation.should_not_receive(:delete!)
      @federation.delete_if_exists!
    end

  end

end
