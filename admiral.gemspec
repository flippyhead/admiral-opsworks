# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "admiral-opsworks"
  spec.version       = '0.0.3'
  spec.authors       = ["Peter T. Brown"]
  spec.email         = ["p@ptb.io"]
  spec.description   = %q{Admiral tasks for wielding AWS OpsWorks resources.}
  spec.summary       = %q{Admiral tasks for wielding AWS OpsWorks resources.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency 'admiral-cloudformation'
end
