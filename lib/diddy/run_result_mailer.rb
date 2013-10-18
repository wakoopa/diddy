module Diddy
  class RunResultMailer
    attr_accessor :run_result

    def initialize(run_result)
      self.run_result = run_result
    end

    #
    #
    #
    def mail(from, to)
      mail_text = RunResultPrinter.new(run_result).to_html
      result = run_result.result ? 'succes' : 'failure'

      Mail.deliver do
        to      to
        from    from
        subject "[Diddy] Run complete: #{result}"

        html_part do
          content_type 'text/html; charset=UTF-8'
          body mail_text
        end
      end
    end
  end
end
