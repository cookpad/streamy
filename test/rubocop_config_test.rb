require "test_helper"
require "net/http"

class RubocopConfigTest < Minitest::Test
  CONFIG_URL = "https://raw.githubusercontent.com/cookpad/guides/master/.rubocop.yml".freeze
  LOCAL      = ".rubocop.yml".freeze
  def setup
    @local  = YAML.safe_load(File.read(LOCAL))
    @remote = YAML.safe_load(Net::HTTP.get_response(URI(CONFIG_URL)).body)
  end

  attr_reader :local, :remote

  def test_rubocop_config
    assert_equal local, remote, "Rubocop config not up to date run: `wget #{CONFIG_URL} -O #{LOCAL}` to update"
  end
end
