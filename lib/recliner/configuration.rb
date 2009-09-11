module Recliner
  # Sets the default Recliner::Document database URI.
  #
  # ==== Parameters
  #
  # * +config+ - either a string (the full database URI) or a hash containing the host, port and database as string keys.
  def self.configuration=(config)
    Document.use_database!(
      case config
      when String
        config
      when Hash
        "http://#{config['host']}:#{config['port']}/#{config['database']}"
      else
        raise ArgumentError, "String or Hash expected"
      end
    )
  end
end
