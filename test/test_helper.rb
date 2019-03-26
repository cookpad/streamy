$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "streamy"
require "minitest/autorun"
require "minitest/focus"
require "mocha/minitest"

ENV["SCHEMA_REGISTRY_URL"] = "http://registry.example.com"
ENV["SCHEMAS_PATH"] = "test/support/schemas"
