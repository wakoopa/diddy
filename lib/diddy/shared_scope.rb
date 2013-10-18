module Diddy
  class SharedScope
    def [](key)
      @vars ||= {}
      @vars[key.to_sym]
    end

    def []=(key, value)
      @vars ||= {}
      @vars[key.to_sym] = value
    end
  end
end
