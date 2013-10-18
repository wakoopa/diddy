# encoding: utf-8
module Diddy
  class Step
    STATE_OK = 1
    STATE_FAILED = 2
    STATE_EXCEPTION = 3
    STATE_PENDING = 4

    attr_accessor :description, :definition, :steps_instance, :run_result

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
      # set the sub steps to 0
      steps_instance.sub_steps = []

      # write to screen
      print(blue(". #{description}"))

      # and to log
      run_result.run_step(description)

      # eval the step
      steps_instance.current_step = self

      # run the step itself
      result = steps_instance.instance_eval(&definition)

      # check if there were any sub steps
      # if so, the result is dependent of those substeps
      if steps_instance.sub_steps.size > 0
        # check result of all sub_steps
        result = steps_instance.sub_steps.all? { |step| step[:valid] }

        # also log
        steps_instance.sub_steps.each do |sub_step|
          run_result.run_sub_step(sub_step[:description])
          run_result.set_sub_step_result(sub_step[:valid])
        end

        # faulty
        print("\n")
      else
        print("\r")

        if result
          print(green("✓ #{description}"))
        else
          print(red(bold("✕ #{description}")))
        end
      end

      # log result of step
      run_result.set_step_result(result)

      # next line
      print("\n")

      # return the result
      result
    end
  end
end
