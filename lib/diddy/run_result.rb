module Diddy
  class RunResult
    attr_accessor :scripts

    #
    # Starts the run of a script. Call this before running a scenario.
    #
    def run_script(description)
      @scripts ||= []
      @current_script = Script.new(description)
      @scripts << @current_script
    end

    #
    # Start the run of an entire scenario.
    #
    def run_scenario(description)
      @current_scenario = Scenario.new(description)
      @current_scenario.script = @current_script

      @current_script.scenarios << @current_scenario
    end

    #
    # Starts run of a step
    #
    def run_step(description)
      @current_step = Step.new(description)
      @current_step.scenario = @current_scenario

      @current_scenario.steps << @current_step
    end

    #
    # Starts run of a sub step
    #
    def run_sub_step(description)
      @current_sub_step = SubStep.new(description)
      @current_sub_step.step = @current_step

      @current_step.sub_steps << @current_sub_step
    end

    #
    # Sets the result of the current step
    #
    def set_step_result(result)
      @current_step.result = result
    end

    #
    # Sets the result to false and logs the exception of the step
    #
    def set_step_exception(exception)
      @current_step.result = false
      @current_step.exception = exception
    end

    #
    # Sets the result of the sub step
    #
    def set_sub_step_result(result)
      @current_sub_step.result = result
    end

    # helper classes
    class Script
      attr_accessor :scenarios, :description

      def initialize(description)
        self.description = description
      end

      def scenarios
        @scenarios ||= []
      end

      def result
        scenarios.all? { |scenario| scenario.result }
      end
    end

    class Scenario
      attr_accessor :steps, :description, :script

      def initialize(description)
        self.description = description
      end

      def steps
        @steps ||= []
      end

      def result
        steps.all? { |step| step.result }
      end
    end

    class Step
      attr_accessor :description, :sub_steps, :result, :scenario, :exception

      def initialize(description)
        self.description = description
      end

      def sub_steps
        @sub_steps ||= []
      end
    end

    class SubStep
      attr_accessor :description, :result, :step

      def initialize(description)
        self.description = description
      end
    end
  end
end
