# encoding: utf-8
module Diddy
  class Script
    STATE_OK = 1
    STATE_FAILED = 2
    STATE_EXCEPTION = 3

    attr_accessor :steps, :scenario, :log

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
    # Full log
    #
    def log
      @log ||= ""
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
        self.class.write_log(scenario)

        @steps.each do |step|
          run_step(step)
        end
        return true

      rescue ScriptAborted
        self.class.write_log("Aborted")
        return false

      end
    end

    #
    # Returns the log of the last run
    #
    def self.last_log
      @last_log ||= ""
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
    # Runs all defined scripts. Returns true if and only if all indivudial
    # scripts returned true. Otherwise returns false.
    #
    def self.run_all
      # empty log
      @last_log = ""

      write_log("[#{Time.now}] Diddy starting to run #{@scripts.size} scripts")

      # Run all scripts and remember their return status
      status = @scripts.map do |script|
        # run the script
        result = script.run

        # concat log of script to general log
        write_log(script.log)

        result
      end

      write_log("[#{Time.now}] Diddy finished running #{@scripts.size} scripts")

      # If one of the scripts returned with "false"; make the entire run
      # return false as well
      status.include?(false) ? false : true
    end

    #
    # Only runs given script
    #
    def self.only_run(scenario)
      @scripts.select { |script| script.scenario == scenario }.first.run
    end

    def self.scripts
      @scripts
    end

    private

    def self.write_log(message, print = true)
      puts(message) if print
      self.last_log << "#{message}\n"
    end

    #
    # Runs one step
    #
    def run_step(step)
      # run proc on this instance as scope
      begin
        result = step.run

      rescue Exception => exception
        log_step(step, STATE_EXCEPTION)
        print_exception(step, exception)
        raise ScriptAborted.new
      end

      if result
        log_step(step, STATE_OK)
      else
        log_step(step, STATE_EXCEPTION)
        raise ScriptAborted.new
      end
    end

    #
    # Logs step to log
    #
    def log_step(step, state)
      if state == STATE_FAILED || state == STATE_EXCEPTION
        print(red(bold("✕ #{step.description}")))
        self.class.write_log("✕ #{step.description}", false)

        if state == STATE_EXCEPTION
          print(" [EXCEPTION]")
          print("\n\n")
          self.class.write_log("[EXCEPTION]", false)
        end
      else
        print(green("✓ #{step.description}"), "\n")
        self.class.write_log("✓ #{step.description}", false)
      end
    end

    #
    # Prints exception thrown by step, on screen
    #
    def print_exception(current_step, exception)
      # print backtrace
      self.class.write_log("- #{exception.message}")
      self.class.write_log("  #{exception.backtrace.join("\n  ")}")
      self.class.write_log("\n")
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
