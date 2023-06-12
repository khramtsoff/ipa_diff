# frozen_string_literal: true

require_relative "lib/ipa_diff/version"

Gem::Specification.new do |spec|
  spec.name = "ipa_diff"
  spec.version = IpaDiff::VERSION
  spec.authors = ["Vladimir Khramtsov"]
  spec.email = ["khramtsov.git@gmail.com"]

  spec.summary = "IPA differ"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "./CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir['lib/**/*']
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rubyzip"
  spec.metadata["rubygems_mfa_required"] = "true"
end
