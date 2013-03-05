require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "allegro_graph"))

describe "statements" do

  use_real_transport!

  before :each do
    @server = AllegroGraph::Server.new :username => ENV['AG_USER'], :password => ENV['AG_PASS']
    @repository = AllegroGraph::Repository.new @server, "test_repository"
    @repository.create_if_missing!

    @statements = @repository.statements
  end

  describe "creation" do

    it "should take a statement" do
      result = @statements.create "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\""
      result.should be_true
    end

  end

  describe "finding" do

    before :each do
      @statements.delete
      @statements.create "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\""
      @statements.create "\"another_subject\"", "\"test_predicate\"", "\"another_object\"", "\"test_context\""
    end

    it "should find all statements" do
      statements = @statements.find
      statements.should == [
        [ "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\"" ],
        [ "\"another_subject\"", "\"test_predicate\"", "\"another_object\"", "\"test_context\"" ]
      ]
    end

    it "should find statements by filter options" do
      statements = @statements.find :subject => "\"test_subject\""
      statements.should == [
        [ "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\"" ]
      ]
    end

  end

  describe "deletion" do

    before :each do
      @statements.create "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\""
    end

    it "should delete all statements" do
      lambda do
        @statements.delete :subject   => "\"test_subject\"",
                           :predicate => "\"test_predicate\"",
                           :object    => "\"test_object\"",
                           :context   => "\"test_context\""
      end.should change(@repository, :size)
    end

  end

end
