# encoding: utf-8
module Diddy
  class Step
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
  end
end
