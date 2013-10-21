module Diddy
  class RunResultMailer
    attr_accessor :run_result

    def initialize(run_result)
      self.run_result = run_result
    end

    #
    #
    #
    def mail(subject, from, to)
      mail_text = RunResultPrinter.new(run_result).to_html

      Mail.deliver do
        to      to
        from    from
        subject subject

        html_part do
          content_type 'text/html; charset=UTF-8'
          body mail_text
        end
      end
    end
  end
end
