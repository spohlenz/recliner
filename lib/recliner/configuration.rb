module Recliner
  def self.configuration=(config)
    Document.use_database!(
      case config
      when String
        config
      when Hash
        "http://#{config['host']}:#{config['port']}/#{config['database']}"
      else
        raise ArgumentError, "string or hash expected"
      end
    )
  end
end
