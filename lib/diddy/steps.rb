# encoding: utf-8
module Diddy
  class Steps
    include Helpers

    attr_accessor :sub_steps, :current_step, :context

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
    # It is also to use sub_steps (not to confuse with dubstep).
    #
    #   step('Do something crazy') do
    #     sub_step('Eat brains') do
    #       a == true
    #     end
    #
    #     sub_step('Go insane') do
    #       b == true
    #     end
    #   end
    #
    # In the case above, every sub_step needs to return true.
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

    #
    # Adds a sub_step
    #
    def sub_step(description, &block)
      # print pending to screen
      print("\n")
      print(blue("  . #{description}"))

      # yield the block
      valid = yield(block)

      # jump back to beginning of line
      print("\r")

      # print out success or failure
      if valid
        print(green("  ✓ #{description}"))
      else
        print(red(bold("  ✕ #{description}")))
      end

      self.sub_steps << { description: description, valid: valid }
    end
  end
end
