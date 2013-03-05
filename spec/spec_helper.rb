require 'rubygems'
require 'rspec'
require 'transport/spec'
require 'dotenv'
Dotenv.load

require File.join(File.dirname(__FILE__), "..", "lib", "allegro_graph")
require File.join(File.dirname(__FILE__), "fake_transport_helper")

def fake_transport!
  Transport::Spec::Faker.fake! File.join(File.dirname(__FILE__), "fake_transport.yml")
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
