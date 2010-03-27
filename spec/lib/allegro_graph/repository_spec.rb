require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "allegro_graph", "repository"))

describe AllegroGraph::Repository do

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @catalog = AllegroGraph::Catalog.new @server, "test_catalog"
    @repository = AllegroGraph::Repository.new @catalog, "test_repository"    
  end

  describe "==" do

    it "should be true when comparing two equal repositories" do
      other = AllegroGraph::Repository.new @catalog, "test_repository"
      @repository.should == other
    end

    it "should be false when comparing two different repositories" do
      other = AllegroGraph::Repository.new @catalog, "other_repository"
      @repository.should_not == other
    end

  end

  describe "path" do

    it "should return the repository path" do
      @repository.path.should == "#{@catalog.path}/repositories/test_repository"
    end

  end

  describe "exists?" do

    context "for a repository that already exists" do

      it "should return true" do
        @repository.exists?.should be_true
      end

    end

    context "for a repository that not exists" do

      before :each do
        @repository.name = "not_existing"
      end

      it "should return false" do
        @repository.exists?.should be_false
      end

    end

  end

  describe "create!" do

    context "for a repository that already exists" do

      it "should return false" do
        @repository.create!.should be_false
      end

    end

    context "for a repository that not exists" do

      before :each do
        @repository.name = "not_existing"
      end

      it "should return true" do
        @repository.create!.should be_true
      end

    end

  end

  describe "create_if_missing!" do

    context "for a repository that already exists" do

      before :each do
        @repository.stub!(:exists?).and_return(true)
      end

      it "should do nothing" do
        @repository.should_not_receive(:create!)
        @repository.create_if_missing!
      end

    end

    context "for a repository that not exists" do

      before :each do
        @repository.stub!(:exists?).and_return(false)
      end

      it "should call create!" do
        @repository.should_receive(:create!)
        @repository.create_if_missing!
      end

    end

  end

  describe "delete!" do

    context "for a repository that already exists" do

      it "should return true" do
        @repository.delete!.should be_true
      end

    end

    context "for a repository that not exists" do

      before :each do
        @repository.name = "not_existing"
      end

      it "should return false" do
        @repository.delete!.should be_false
      end

    end

  end

  describe "delete_if_exists!" do

    context "for a repository that already exists" do

      before :each do
        @repository.stub!(:exists?).and_return(true)
      end

      it "should call delete!" do
        @repository.should_receive(:delete!)
        @repository.delete_if_exists!
      end

    end

    context "for a repository that not exists" do

      before :each do
        @repository.stub!(:exists?).and_return(false)
      end

      it "should do nothing" do
        @repository.should_not_receive(:delete!)
        @repository.delete_if_exists!
      end

    end

  end

  describe "size" do

    it "should return the number of statements" do
      @repository.size.should == 3
    end
    
  end

  describe "add_statement" do

    before :each do
      @subject    = "test_subject"
      @predicate  = "test_predicate"
      @object     = "test_object"
    end

    

  end

end
