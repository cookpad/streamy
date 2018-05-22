# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'streamy/version'

Gem::Specification.new do |spec|
  spec.name          = "streamy"
  spec.version       = Streamy::VERSION
  spec.authors       = ["Jens Balvig"]
  spec.email         = ["jens@balvig.com"]

  spec.summary       = %q{Basic toolset for hooking into event stream}
  spec.description   = %q{Library for enabling asynchronous inter-service communication}
  spec.homepage      = "https://github.com/cookpad/streamy"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "mocha", "~> 1.4"
  spec.add_development_dependency "pry", "~> 0.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.7"

  spec.add_dependency "activesupport", "~> 5.1"
  spec.add_dependency "hutch", "~> 0.25"
  spec.add_dependency "webmock", "~> 3.3"
end
