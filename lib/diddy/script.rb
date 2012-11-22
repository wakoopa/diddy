module Diddy
  class Script
    attr_accessor :steps, :scenario

    #
    # Creates a script
    #
    def initialize(scenario)
      @scenario = scenario
    end

    #
    # Determines which step classes should be used
    #
    def uses(klass)
      @steps_instances ||= []
      @steps_instances << klass.new(shared_scope)
    end

    #
    # Describes which step should be run
    #
    def step(description)
      @steps ||= []

      # find step klass
      steps_instance = find_steps_instance_for(description)

      # check if step exists
      if steps_instance.class.has_step?(description)
        @steps << Diddy::Step.new(
          description:      description, 
          steps_instance:   steps_instance, 
          definition:       steps_instance.class.definition(description)
        )
      else
        raise "Step '#{description}' not defined"
      end
    end

    #
    # Runs all the steps in the script
    #
    def run
      begin
        puts scenario

        @steps.each do |step|
          run_step(step)
        end
      rescue ScriptAborted
        puts "Aborted"
      end
    end

    #
    # Defines a script
    #   
    #   Diddy::Script.define('Test API') do 
    #     uses ApiSteps
    #     uses LoginSteps
    #
    #     step 'Do something'
    #     step 'Do something else'
    #   end
    #
    def self.define(scenario, &block)
      @scripts ||= []

      script = self.new(scenario)
      script.instance_eval(&block)

      @scripts << script
    end

    #
    # Runs all defined scripts
    #
    def self.run_all
      @scripts.each { |script| script.run }
    end

    #
    # Only runs given script
    #
    def self.only_run(scenario)
      @scripts.select { |script| script.scenario == scenario }.first.run
    end

    private

    #
    # Runs one step
    #
    def run_step(step)
      # run proc on this instance as scope
      begin
        result = step.run

      rescue Exception => exception
        step.log(Diddy::Step::STATE_EXCEPTION)
        print_exception(step, exception)
        raise ScriptAborted.new
      end

      if result
        step.log(Diddy::Step::STATE_OK)
      else
        step.log(Diddy::Step::STATE_EXCEPTION)
        raise ScriptAborted.new
      end
    end

    #
    # Prints exception thrown by step, on screen
    #
    def print_exception(current_step, exception)
      # print backtrace
      puts "- #{exception.message}"
      puts "  #{exception.backtrace.join("\n  ")}"
      puts "\n"
    end

    #
    # Finds the instance of the steps definition by step name
    #
    def find_steps_instance_for(description)
      @steps_instances.each do |instance|
        if instance.class.steps && instance.class.steps.has_key?(description)
          return instance
        end
      end

      nil
    end

    def shared_scope
      @shared_scope ||= SharedScope.new
    end

    class ScriptAborted < Exception; end

  end
end
