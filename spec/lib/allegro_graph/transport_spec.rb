require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "allegro_graph", "transport"))

describe AllegroGraph::Transport do

  use_real_transport!
    
  describe "request" do

    before :each do
      @http_method = :get
      @url = "http://localhost:5984/"
      @options = { }

      @request = Net::HTTP::Get.new "/", { }
      @response = Object.new
      @response.stub!(:code).and_return("200")
      @response.stub!(:body).and_return("test")
      Net::HTTP.stub!(:start).and_return(@response)
    end

    def do_request(options = { })
      AllegroGraph::Transport.request @http_method, @url, @options.merge(options)
    end

    it "should initialize the correct request object" do
      Net::HTTP::Get.should_receive(:new).with("/", { }).and_return(@request)
      do_request
    end

    it "should perform the request" do
      Net::HTTP.should_receive(:start).and_return(@response)
      do_request
    end

    it "should return the response" do
      do_request.body.should == "test"
    end

  end

end

describe AllegroGraph::ExtendedTransport do

  use_real_transport!

  describe "request" do

    before :each do
      @http_method = :get
      @url = "http://localhost:5984/"
      @options = {
        :auth_type            => :basic,
        :username             => "test",
        :password             => "test",
        :expected_status_code => 200
      }

      @request = Net::HTTP::Get.new "/", { }
      @response = Object.new
      @response.stub!(:code).and_return("200")
      @response.stub!(:body).and_return("{\"test\":\"test\"}")
      Net::HTTP.stub!(:start).and_return(@response)
    end

    def do_request(options = { })
      AllegroGraph::ExtendedTransport.request @http_method, @url, @options.merge(options)
    end

    it "should initialize the correct request object" do
      Net::HTTP::Get.should_receive(:new).with(
        "/", { "Authorization" => "Basic dGVzdDp0ZXN0\n", "Accept" => "application/json" }
      ).and_return(@request)
      do_request
    end

    it "should perform the request" do
      Net::HTTP.should_receive(:start).and_return(@response)
      do_request
    end

    it "should return the parsed response" do
      do_request.should == { "test" => "test" }
    end

    it "should raise NotImplementedError if the given auth_type is wrong" do
      lambda do
        do_request :auth_type => :invalid
      end.should raise_error(NotImplementedError)
    end

    it "should raise UnexpectedStatusCodeError if responded status code is wrong" do
      lambda do
        do_request :expected_status_code => 201
      end.should raise_error(AllegroGraph::ExtendedTransport::UnexpectedStatusCodeError)
    end

  end

end
