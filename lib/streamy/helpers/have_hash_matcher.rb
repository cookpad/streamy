RSpec::Matchers.define :have_hash do |expected|
  match do |array|
    synchronize do
      hash = find_hash(array, expected)

      expect(hash).to include(expected)
      expect(hash).to_not include(@unexpected_keys)
    end
  end

  chain :without do |*unexpected_keys|
    @unexpected_keys = unexpected_keys
  end

  failure_message do
    @failure_message
  end

  private

    def find_hash(array, expected)
      hash = array.reverse.find do |item|
        find_with_inclusion(item, expected)
      end

      hash || better_diff(array)
    end

    def find_with_inclusion(hash, expected)
      expect(hash).to include(expected)
    rescue RSpec::Expectations::ExpectationNotMetError
    end

    def better_diff(array)
      return array if array.size > 1

      array.first
    end

    # mimicking has_text/css? matchers, https://git.io/vMSo9
    def synchronize(&block)
      start_time = Time.current

      begin
        yield
      rescue ::RSpec::Expectations::ExpectationNotMetError => e
        @failure_message = e.message
        raise(e) unless Capybara.current_driver == Capybara.javascript_driver

        return false if (Time.current - start_time) >= Capybara.default_max_wait_time
        sleep 0.05
        retry
      end
    end
end

