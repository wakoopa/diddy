module Diddy
  class RunResultPrinter
    attr_accessor :run_result

    def initialize(run_result)
      self.run_result = run_result
    end

    #
    # Converts the result to a string
    #
    def to_s
      text = ""

      run_result.scripts.each do |script|
        text << "# #{script.description}\n"

        script.scenarios.each do |scenario|
          if scenario.result
            text << "## #{scenario.description}\n\n"
          else
            text << "## [X] #{scenario.description}\n\n"
          end

          scenario.steps.each do |step|
            if step.result
              text << "  * #{step.description}\n"
            else
              text << "  * [X] #{step.description}\n"
            end

            if step.exception
              text << "#{step.exception.message}: \n\n#{step.exception.backtrace.join("\n")}\n\n"
            end

            if step.sub_steps.any?
              step.sub_steps.each do |sub_step|
                if sub_step.result
                  text << "    * #{sub_step.description}\n"
                else
                  text << "    * [X] #{sub_step.description}\n"
                end
              end
            end
          end
        end
      end

      text
    end

    #
    # Converts the result to HTML
    #
    # @TODO needs to be refactored to a templating language. Quick hack for now.
    #
    def to_html
      html = "<html><head><style type='text/css'>.error { color: red }; .ok { color: green }; pre { display: block; margin: 1em; };</style><title>Run results</title></head><body>"

      # walk over all scripts
      run_result.scripts.each do |script|
        html << "<h2>#{script.description}</h2>"

        # walk of the scenarios
        script.scenarios.each do |scenario|
          # result was ok? than only log the scenario itself
          if scenario.result
            html << "<h3 class='ok' style='color: green;'>#{scenario.description}</h3>"
          else
            # log the error and it's steps
            html << "<h3 class='error' style='color: red;'>#{scenario.description}</h3>"
            html << "<ul>"

            # walk over the steps
            scenario.steps.each do |step|
              # output step
              if step.result
                html << "<li class='ok' style='color: green;'>#{step.description}"
              else
                html << "<li class='error' style='color: red;'>#{step.description}"
              end

              # was there an exception?
              if step.exception
                html << "<pre>#{step.exception.message}\n\n#{step.exception.backtrace.join("\n")}</pre>"
              end

              # are there any sub steps?
              if step.sub_steps.any?
                html << "<ul>"

                # walk over sub steps
                step.sub_steps.each do |sub_step|
                  if sub_step.result
                    html << "<li class='ok' style='color: green;'>#{sub_step.description}</li>"
                  else
                    html << "<li class='error' style='color: red;'>#{sub_step.description}</li>"
                  end
                end

                html << "</ul></li>"
              else
                html << "</li>"
              end
            end

            html << "</ul>"
          end
        end
      end

      html << "</body>"
      html
    end
  end
end
