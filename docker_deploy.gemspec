# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docker_deploy/version'

Gem::Specification.new do |spec|
  spec.name          = "docker_deploy"
  spec.version       = DockerDeploy::VERSION
  spec.authors       = ["Jonas Nicklas", "Lisa Hammarström"]
  spec.email         = ["jonas.nicklas@gmail.com", "lisa@elabs.se"]
  spec.summary       = %q{Deploy Docker containers via Rake}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sshkit", "~> 1.5"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
