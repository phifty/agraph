require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "allegro_graph", "resource"))

describe AllegroGraph::Resource do

  before :each do
    @resource = AllegroGraph::Resource.new
  end

  it "should the statements proxy" do
    @resource.statements.should be_instance_of(AllegroGraph::Proxy::Statements)
  end

  it "should the query proxy" do
    @resource.query.should be_instance_of(AllegroGraph::Proxy::Query)
  end

  it "should the geometric proxy" do
    @resource.geometric.should be_instance_of(AllegroGraph::Proxy::Geometric)
  end

  it "should the mapping proxy" do
    @resource.mapping.should be_instance_of(AllegroGraph::Proxy::Mapping)
  end

end
