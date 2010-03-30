require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "allegro_graph"))

describe "integration" do

  use_real_transport!

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @repository = AllegroGraph::Repository.new @server, "test_repository"    
  end

  describe "basic server functions" do

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

  describe "repository listing" do

    before :each do
      @repository.create_if_missing!
    end

    it "should provide a list of repositories" do
      @server.root_catalog.repositories.should == [ @repository ]
    end

  end

  describe "repository creation" do

    before :each do
      @repository.delete_if_exists!
    end

    it "should create the repository" do
      lambda do
        @repository.create!
      end.should change(@repository, :exists?).from(false).to(true)
    end

  end

  describe "repository deletion" do

    before :each do
      @repository.create_if_missing!
    end

    it "should delete the repository" do
      lambda do
        @repository.delete!
      end.should change(@repository, :exists?).from(true).to(false)
    end

  end

  describe "statements" do

    before :each do
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

  describe "query bypass" do

    before :each do
      @repository.create_if_missing!

      statements = @repository.statements
      statements.create "\"test_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"test_object\"", "\"test_context\""
      statements.create "\"another_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"another_object\"", "\"test_context\""
    end

    context "sparql" do

      before :each do
        @repository.query.language = :sparql
      end
      
      it "should respond to queried data" do
        result = @repository.query.perform "SELECT ?subject WHERE { ?subject <http://xmlns.com/foaf/0.1/knows> ?object . }"
        result["names"].should include("subject")
        result["values"].should include([ "\"another_subject\"" ], [ "\"test_subject\"" ])
      end

    end

    context "prolog" do

      before :each do
        @repository.query.language = :prolog
      end

      it "should respond to queried data" do
        result = @repository.query.perform "(select (?subject) (q- ?subject !<http://xmlns.com/foaf/0.1/knows> ?object))"
        result["names"].should include("subject")
        result["values"].should include([ "\"another_subject\"" ], [ "\"test_subject\"" ])
      end

    end

  end

  describe "geo-spatial data" do

    before :each do
      @repository.create_if_missing!
      @geometric  = @repository.geometric
      @statements = @repository.statements
    end

    describe "types" do

      it "should provide a cartesian type" do
        result = @geometric.cartesian_type :strip_width => 1.0,
                                           :x_min       => 2.0,
                                           :y_min       => 2.0,
                                           :x_max       => 20.0,
                                           :y_max       => 20.0
        result.should == "<http://franz.com/ns/allegrograph/3.0/geospatial/cartesian/2.0/20.0/2.0/20.0/1.0>"
      end

      it "should provide a spherical type" do
        result = @geometric.spherical_type :strip_width   => 1.0,
                                           :latitude_min  => 2.0,
                                           :longitude_min => 2.0,
                                           :latitude_max  => 20.0,
                                           :longitude_max => 20.0
        result.should == "<http://franz.com/ns/allegrograph/3.0/geospatial/spherical/degrees/2.0/20.0/2.0/20.0/1.0>"
      end
      
    end

    describe "creating polygon" do

      before :each do
        @type = @geometric.cartesian_type :strip_width => 1.0,
                                          :x_min       => 2.0,
                                          :y_min       => 2.0,
                                          :x_max       => 20.0,
                                          :y_max       => 20.0
        @polygon = [ [ 2.0, 2.0 ], [ 11.0, 2.0 ], [ 11.0, 11.0 ], [ 2.0, 11.0 ] ]
      end

      it "should return true" do
        result = @geometric.create_polygon @polygon, :name => "test_polygon", :type => @type
        result.should be_true
      end
      
    end

    context "in a cartesian system" do

      before :each do
        @type = @geometric.cartesian_type :strip_width => 1.0,
                                          :x_min       => 2.0,
                                          :y_min       => 2.0,
                                          :x_max       => 20.0,
                                          :y_max       => 20.0
        @statements.create "\"test_subject\"", "\"at\"", "\"+10+10\"^^#{@type}"
        @statements.create "\"another_subject\"", "\"at\"", "\"+15+15\"^^#{@type}"
      end

      it "should find objects inside a box" do
        result = @statements.find_inside_box :type       => @type,
                                             :predicate  => "\"at\"",
                                             :x_min      => 8.0,
                                             :y_min      => 8.0,
                                             :x_max      => 11.0,
                                             :y_max      => 11.0
        result.should include([ "\"test_subject\"", "\"at\"", "\"+10.000000000931323+10.000000000931323\"^^#{@type}"])
        result.should_not include([ "\"another_subject\"", "\"at\"", "\"+15.000000000465661+15.000000000465661\"^^#{@type}"])
      end

      it "should find objects inside a circle" do
        result = @statements.find_inside_circle :type      => @type,
                                                :predicate => "\"at\"",
                                                :x         => 9.0,
                                                :y         => 9.0,
                                                :radius    => 2.0
        result.should include([ "\"test_subject\"", "\"at\"", "\"+10.000000000931323+10.000000000931323\"^^#{@type}"])
        result.should_not include([ "\"another_subject\"", "\"at\"", "\"+15.000000000465661+15.000000000465661\"^^#{@type}"])
      end

      context "with a defined polygon" do

        before :each do
          @type = @geometric.cartesian_type :strip_width => 1,
                                            :x_min       => -100,
                                            :y_min       => -100,
                                            :x_max       => 100,
                                            :y_max       => 100
          @statements.create "\"test_subject\"", "\"at\"", "\"+1+1\"^^#{@type}"
          @geometric.create_polygon [ [ 0, -100 ], [ 0, 100 ], [ 100, 100 ], [ 100, -100 ] ],
                                    :name => "test_polygon",
                                    :type => @type
        end

        it "should find objects inside that polygon" do
          pending
          result = @statements.find_inside_polygon :type         => @type,
                                                   :predicate    => "\"at\"",
                                                   :polygon_name => "test_polygon"
          result.should include([ "\"test_subject\"", "\"at\"", "\"+1+1\"^^<http://franz.com/ns/allegrograph/3.0/geospatial/cartesian/2.0/20.0/2.0/20.0/1.0>"])
        end

      end

    end

    context "in a spherical system" do

      before :each do
        @type = @geometric.spherical_type :strip_width   => 1.0,
                                          :latitude_min  => 2.0,
                                          :longitude_min => 2.0,
                                          :latitude_max  => 20.0,
                                          :longitude_max => 20.0
        @statements.create "\"test_subject\"", "\"at\"", "\"+10.00+010.00\"^^#{@type}"
      end

      it "should find objects inside a haversine" do
        result = @statements.find_inside_haversine :type       => @type,
                                                   :predicate  => "\"at\"",
                                                   :latitude   => 9.0,
                                                   :longitude  => 9.0,
                                                   :radius     => 200.0,
                                                   :unit       => :km
        result.should include([ "\"test_subject\"", "\"at\"", "\"+100000+0100000\"^^<http://franz.com/ns/allegrograph/3.0/geospatial/spherical/degrees/2.0/20.0/2.0/20.0/1.0>"])
      end

    end

  end

  describe "transactions" do

    before :each do
      @repository.statements.delete
    end

    it "should commit all changes at once" do
      @repository.transaction do
        statements.create "\"test_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"test_object\""
        statements.create "\"another_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"another_object\""
      end

      result = @repository.statements.find
      result.should include([ "\"test_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"test_object\"" ])
      result.should include([ "\"another_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"another_object\"" ])
    end

    it "should rollback on error" do
      lambda do
        @repository.transaction do
          statements.create "\"test_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"test_object\""
          statements.create "\"another_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"another_object\""
          invalid
        end
      end.should raise_error(NameError)

      result = @repository.statements.find
      result.should_not include([ "\"test_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"test_object\"" ])
      result.should_not include([ "\"another_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"another_object\"" ])
    end

  end

  describe "federations" do

    before :each do
      @federation = AllegroGraph::Federation.new @server, "test_federation", :repository_names => [ @repository.name ]
    end
    
    it "should create a federation" do
      @federation.delete_if_exists!
      @federation.create!.should be_true
    end

    it "should list the federations" do
      @federation.create_if_missing!
      @server.federations.should include(@federation)
    end

    it "should delete a federation" do
      @federation.create_if_missing!
      @federation.delete!.should be_true
    end

  end

  describe "type mapping" do

    before :each do
      @repository.create_if_missing!
      @statements = @repository.statements
      @mapping    = @repository.mapping
    end

    describe "creating a type" do

      it "should return true" do
        result = @mapping.create "<time>", "<http://www.w3.org/2001/XMLSchema#dateTime>"
        result.should be_true
      end

    end

    describe "creating a type" do

      before :each do
        @mapping.create "<time>", "<http://www.w3.org/2001/XMLSchema#dateTime>"
      end

      it "should return true" do
        result = @mapping.delete "<time>"
        result.should be_true
      end

    end

    describe "using a type for a range query" do

      before :each do
        @mapping.create "<time>", "<http://www.w3.org/2001/XMLSchema#dateTime>"
        @statements.create "\"event_one\"", "<happened>", "\"2010-03-29T17:00:00\"^^<time>"
        @statements.create "\"event_two\"", "<happened>", "\"2010-03-29T18:00:00\"^^<time>"
        @statements.create "\"event_three\"", "<happened>", "\"2010-03-29T19:00:00\"^^<time>"
      end

      it "should findthe statements for the given time" do
        result = @statements.find :predicate => "<happened>", :object => [ "\"2010-03-29T16:30:00\"^^<time>", "\"2010-03-29T18:30:00\"^^<time>" ]
        result.should include([ "\"event_one\"", "<happened>", "\"2010-03-29T17:00:00Z\"^^<http://www.w3.org/2001/XMLSchema#dateTime>" ])
        result.should include([ "\"event_two\"", "<happened>", "\"2010-03-29T18:00:00Z\"^^<http://www.w3.org/2001/XMLSchema#dateTime>" ])
        result.should_not include([ "\"event_three\"", "<happened>", "\"2010-03-29T19:00:00Z\"^^<http://www.w3.org/2001/XMLSchema#dateTime>" ])
      end

    end

  end

end
