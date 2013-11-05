module Diddy
  module Helpers
    def try(max_times, delay = 1, &block)
      index = 0
      result = false

      while !result && index < max_times do
        result = yield
        sleep(delay) unless result
        index += 1
      end

      result
    end

    def try_with_exception(max_times, delay = 1, &block)
      index = 0
      result = false

      while !result && index < max_times do
        begin
          result = yield
        rescue Exception
          result = false
        end

        sleep(delay) unless result
        index += 1
      end

      result
    end
  end
end
