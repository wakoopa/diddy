module Diddy
  class Context
    def initialize(vars)
      @vars = vars
    end

    def [](key)
      @vars[key.to_sym]
    end
  end
end
