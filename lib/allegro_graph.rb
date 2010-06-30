
module AllegroGraph

  autoload :Transport,          File.join(File.dirname(__FILE__), "allegro_graph", "transport")
  autoload :ExtendedTransport,  File.join(File.dirname(__FILE__), "allegro_graph", "extended_transport")
  autoload :Server,             File.join(File.dirname(__FILE__), "allegro_graph", "server")
  autoload :Catalog,            File.join(File.dirname(__FILE__), "allegro_graph", "catalog")
  autoload :Resource,           File.join(File.dirname(__FILE__), "allegro_graph", "resource")
  autoload :Repository,         File.join(File.dirname(__FILE__), "allegro_graph", "repository")
  autoload :Session,            File.join(File.dirname(__FILE__), "allegro_graph", "session")
  autoload :Proxy,              File.join(File.dirname(__FILE__), "allegro_graph", "proxy")
  autoload :Utility,            File.join(File.dirname(__FILE__), "allegro_graph", "utility")

end
