module Diddy
  class RunResultPrinter
    attr_accessor :run_result

    def initialize(run_result)
      self.run_result = run_result
    end

    #
    # Converts the result to HTML
    #
    # @TODO needs to be refactored to a templating language. Quick hack for now.
    #
    def to_html
      html = "<html><head><style type='text/css'>.error { color: red }; pre { display: block; margin: 1em; };</style><title>Run results</title></head><body>"

      # walk over all scripts
      run_result.scripts.each do |script|
        html << "<h2>#{script.description}</h2>"

        # walk of the scenarios
        script.scenarios.each do |scenario|
          # result was ok? than only log the scenario itself
          if scenario.result
            html << "<h3>#{scenario.description}</h3>"
          else
            # log the error and it's steps
            html << "<h3 class='error'>#{scenario.description}</h3>"
            html << "<ul>"

            # walk over the steps
            scenario.steps.each do |step|
              # output step
              if step.result
                html << "<li>#{step.description}"
              else
                html << "<li class='error'>#{step.description}"
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
                    html << "<li>#{sub_step.description}</li>"
                  else
                    html << "<li class='error'>#{sub_step.description}</li>"
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
