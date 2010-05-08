
module AllegroGraph

  module Proxy

    autoload :Statements, File.join(File.dirname(__FILE__), "proxy", "statements")
    autoload :Query,      File.join(File.dirname(__FILE__), "proxy", "query")
    autoload :Geometric,  File.join(File.dirname(__FILE__), "proxy", "geometric")
    autoload :Mapping,    File.join(File.dirname(__FILE__), "proxy", "mapping")

  end

end
