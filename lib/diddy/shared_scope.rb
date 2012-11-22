module Diddy
  class SharedScope
    def method_missing(method, *args)
      if method =~ /=$/
        vars[method.to_s[0..-2]] = args.first
      elsif args.size == 0
        vars[method.to_s]
      end
    end

    private
    
    def vars
      @vars ||= {}
    end

  end
end
