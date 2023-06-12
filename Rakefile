# frozen_string_literal: true

require "bundler/gem_tasks"
require "rubocop/rake_task"

RuboCop::RakeTask.new do |task|
  task.options = ["--autocorrect"]
end

desc "Increment version"
task :increment do
  version_file = "lib/ipa_diff/version.rb"
  version_contents = File.read(version_file)
  version_match = version_contents.match(/VERSION = "(\d+\.\d+\.\d+)"/)
  current_version = version_match[1]

  # Increment the patch version
  new_version = current_version.split('.').tap { |v| v[2] = v[2].to_i + 1 }.join('.')

  # Update the version file
  new_contents = version_contents.gsub(/VERSION = '#{current_version}'/, "VERSION = '#{new_version}'")
  File.write(version_file, new_contents)

  puts "Version incremented from #{current_version} to #{new_version}"
end

task default: %i[rubocop]
