module Diddy
  #
  # A scenario contains several steps. This is where the real work is done.
  #
  class Scenario
    attr_accessor :script, :context, :description, :steps, :run_result

    #
    # Creates a scenario
    #
    def initialize(options = {})
      options.each { |k,v| send("#{k}=", v) }
    end

    #
    # Reset me
    #
    def reset!
      instance_variables.each do |var|
        unless %w(@script @context @description @steps @run_result).include?(var.to_s)
          remove_instance_variable(var)
        end
      end
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
      if steps_instance && steps_instance.class.has_step?(description)
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
        @resetted = {}

        # also log
        puts("Scenario: #{description}")
        run_result.run_scenario("Scenario: #{description}")

        @steps.each do |step|
          run_step(step)
        end

        true

      rescue ScenarioAborted
        false

      end
    end

    #
    # Runs one step
    #
    def run_step(step)
      # run proc on this instance as scope
      begin
        # check if we need to reset the step instance
        unless @resetted[step.steps_instance.object_id]
          step.steps_instance.reset!
          @resetted[step.steps_instance.object_id] = true
        end

        step.run_result = run_result
        step.context = context

        result = step.run

      rescue Exception => exception
        print_exception(exception)
        run_result.set_step_exception(exception)

        raise ScenarioAborted.new
      end

      unless result
        raise ScenarioAborted.new
      end
    end

    #
    # Prints exception thrown by step, on screen
    #
    def print_exception(exception)
      print("\n")

      # print backtrace
      puts("- #{exception.message}")
      puts("  #{exception.backtrace.join("\n  ")}")
      puts("\n")
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

    #
    # Runs a given scenario
    #
    def self.run(run_result, scenario, options = {})
      scenario.reset!
      scenario.context = Context.new(options)
      scenario.run_result = run_result
      scenario.run
    end

    class ScenarioAborted < Exception; end
  end
end
