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

    it "should return the response body" do
      do_request.should == "test"
    end

    it "should raise UnexpectedStatusCodeError if an unexpected status id returned" do
      lambda do
        do_request :expected_status_code => 201
      end.should raise_error(AllegroGraph::Transport::UnexpectedStatusCodeError)
    end

  end

  describe "serialize_parameters" do

    before :each do
      @parameters = { :test => 1, :another_test => :test }
    end

    it "should return an empty string on empty parameter hash" do
      AllegroGraph::Transport.send(:serialize_parameters, { }).should == ""
    end
    
    it "should serialize the given parameters" do
      AllegroGraph::Transport.send(:serialize_parameters, @parameters).should == "?another_test=test&test=1"
    end

  end

end

describe AllegroGraph::AuthorizedTransport do

  describe "request" do

    before :each do
      AllegroGraph::Transport.stub!(:request)
    end

    it "should call Transport.request with extended headers" do
      AllegroGraph::Transport.should_receive(:request).with(
        :get, "/", hash_including(:headers => { "Authorization" => "Basic dGVzdDp0ZXN0\n" })
      )
      AllegroGraph::AuthorizedTransport.request :get, "/", :auth_type => :basic, :username => "test", :password => "test"
    end

  end

end

describe AllegroGraph::JSONTransport do

  describe "request" do

    before :each do
      AllegroGraph::AuthorizedTransport.stub!(:request)
    end

    it "should call Transport.request with extended headers" do
      AllegroGraph::AuthorizedTransport.should_receive(:request).with(
        :get, "/", hash_including(:headers => { "Accept" => "application/json", "Content-Type" => "application/json" })
      )
      AllegroGraph::JSONTransport.request :get, "/"
    end

    it "should call AuthorizedTransport.request and parse the response" do
      AllegroGraph::AuthorizedTransport.should_receive(:request).and_return("{\"test\":\"test\"}")
      AllegroGraph::JSONTransport.request(:get, "/").should == { "test" => "test" }
    end

    it "should return nil if AuthorizedTransport.request returns nothing" do
      AllegroGraph::AuthorizedTransport.should_receive(:request).and_return("")
      AllegroGraph::JSONTransport.request(:get, "/").should be_nil
    end

  end

end
