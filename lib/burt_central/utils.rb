module BurtCentral
  module Utils
    # Recursively changes all keys to symbols
    def symbolize_keys(conf)
      return conf unless conf.is_a?(Hash)
      conf.keys.inject({}) do |c, k|
        c[k.to_sym] = symbolize_keys(conf[k])
        c
      end
    end
  end
end