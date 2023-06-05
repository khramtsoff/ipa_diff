# frozen_string_literal: true

require "ipa_diff/ipa_strings_comparison"

module IpaDiff
  def self.compare(ipa_path1, ipa_path2, save_common_strings: false, verbose: false)
    comparison = IpaStringsComparison.new(ipa_path1, ipa_path2, verbose: verbose)
    result = comparison.compare_ipa_strings(save_common_strings: save_common_strings)
    display_result(result, verbose: verbose)
  end

  def self.display_result(result, verbose: false)
    common_strings = result[:common_strings]
    different_strings = result[:different_strings]

    all = common_strings.count + different_strings.count

    percent = common_strings.count * 100 / all

    puts
    puts "Number of common lines: #{common_strings.count}"
    puts "Number of different lines: #{different_strings.count}"
    puts "Percentage of common lines: #{percent}%"
    puts

    if verbose
      puts "Common String lines:"
      common_strings.each do |string|
        puts string
      end

      puts "\nDifferent Strings:"
      different_strings.each do |string|
        puts string
      end
    end

    duplicates = result[:same_sha256]

    if duplicates.empty?
      "No files with the same SHA256 found."
    else
      puts "Found #{duplicates.size} files with the same SHA256"
      if verbose
        duplicates.each do |sha256, files|
          puts "Files with the same SHA256 hash (#{sha256}) in both directories:"
          files.each { |file| puts "- #{file}" }
        end
      end
    end
  end
end
