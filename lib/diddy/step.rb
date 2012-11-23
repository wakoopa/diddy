# encoding: utf-8
module Diddy
  class Step
    STATE_OK = 1
    STATE_FAILED = 2
    STATE_EXCEPTION = 3

    attr_accessor :description, :definition, :steps_instance

    #
    # Initializes step
    #
    def initialize(attrs)
      attrs.each { |k,v| send("#{k}=", v) }
    end

    #
    # Runs the step
    #
    def run
      steps_instance.instance_eval(&definition)
    end

    #
    # Logs state of step to screen
    #
    def log(state)
      if state == STATE_FAILED || state == STATE_EXCEPTION
        print red(bold("✕ #{description}"))
        print " [EXCEPTION]" if state == STATE_EXCEPTION
        print "\n\n"
      else
        print green("✓ #{description}"), "\n"
      end
    end
  end
end
