module Recliner
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
