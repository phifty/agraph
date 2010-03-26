require 'rubygems'
gem 'rspec', '1.3.0'
require 'spec'

require File.join(File.dirname(__FILE__), "fake_transport_helper")

FakeTransport.enable!
Spec::Runner.configure do |configuration|
  configuration.before :each do
    FakeTransport.fake!
  end
end

def use_real_transport!
  class_eval do

    before :all do
      FakeTransport.disable!
    end

    after :all do
      FakeTransport.enable!
    end

  end
end
