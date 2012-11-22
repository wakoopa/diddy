module Diddy
  class Steps
    include Helpers

    def initialize(shared_scope)
      @shared_scope = shared_scope
    end

    #
    # Describes a step
    #
    #   step('Do something crazy') do
    #     ...
    #     a == true
    #   end
    #
    # Steps must return TRUE to keep the script running.
    # When a step returns a FALSE, it will stop the script.
    #
    def self.step(description, &block)
      @steps ||= {}
      @steps[description] = block
    end

    #
    # Returns the defined steps
    #
    def self.steps
      @steps
    end

    #
    # Checks if a step is defined
    #
    def self.has_step?(description)
      @steps && @steps.has_key?(description)
    end

    #
    # Returns proc for step
    #
    def self.definition(description)
      @steps[description]
    end

    #
    # Returns shared scope
    #
    def shared
      @shared_scope
    end
  end
end
