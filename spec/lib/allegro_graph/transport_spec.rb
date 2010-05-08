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

    context "with parameters" do

      before :each do
        @options.merge! :parameters => { :foo => "bar", :test => [ "value1", "value2" ] }
      end

      it "should initialize the correct request object" do
        Net::HTTP::Get.should_receive(:new).with(
          "/?foo=bar&test=value1&test=value2", { }
        ).and_return(@request)
        do_request
      end

    end

  end

end
