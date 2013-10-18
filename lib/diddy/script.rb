# encoding: utf-8
module Diddy
  #
  # A script contains several scenarios. A script can be a recipe, an application etc.
  #
  class Script
    attr_accessor :scenarios, :description, :context, :run_result

    def initialize(description)
      self.description = description
    end

    #
    # Defines a new scenario
    #
    #    scenario('Do something') do
    #       uses SomeSteps
    #
    #       step 'Do this'
    #       step 'Do that'
    #     end
    #
    def scenario(description, &block)
      @scenarios ||= []

      # instantiate scenario
      scenario = Scenario.new(
        script: self,
        context: context,
        description: description,
        run_result: run_result
      )

      # run the DSL
      scenario.instance_eval(&block)

      # add to our collection of scenarios
      @scenarios << scenario
    end

    #
    # Run the script
    #
    def run
      scenarios.each_with_index do |scenario, index|
        # print on screen
        puts("Scenario #{index + 1}: #{scenario.description}")

        # also log
        run_result.run_scenario("Scenario #{index + 1}: #{scenario.description}")

        # run all the steps within the scenario
        scenario.run_result = run_result
        scenario.context = context
        scenario.run

        puts("\n")
      end
    end

    #
    # Defines a new script
    #
    #     Diddy::Script.define('Some recipe') do
    #       scenario('Putting stuff in a bowl') do
    #         step 'Put milk in it'
    #         step 'Drink from bowl'
    #       end
    #     end
    #
    def self.define(description, &block)
      @scripts ||= []

      script = self.new(description)
      script.instance_eval(&block)

      @scripts << script

      script
    end

    #
    # Returns all the defined scripts
    #
    def self.scripts
      @scripts
    end

    #
    # Runs a given script
    #
    def self.run(run_result, description, options = {})
      # find script
      script = scripts.find { |script| script.description == description }
      raise CannotFindScriptError.new("Cannot find script #{description}") unless script

      # output and run
      if options.any?
        vars = " (" + options.map { |k, v| "#{k}=#{v}" }.join(', ') + ")"
      else
        vars = ""
      end

      # print to screen what we are doing
      puts(bold("Running #{description}#{vars}"))

      # also log to result logger
      run_result.run_script("Running #{description}#{vars}")

      # apply the context and run result
      script.context = Context.new(options)
      script.run_result = run_result

      # run the entire script
      script.run
    end

    class CannotFindScriptError < StandardError; end
  end
end
