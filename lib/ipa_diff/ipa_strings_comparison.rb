# frozen_string_literal: true

require "zip"
require "tempfile"
require "digest"

module IpaDiff
  class IpaStringsComparison
    def initialize(ipa_path1, ipa_path2, verbose: false)
      @ipa_path1 = ipa_path1
      @ipa_path2 = ipa_path2
      @verbose = verbose
    end

    def unzip_ipa(ipa_path)
      unzip_directory = Dir.mktmpdir

      puts "unzip_directory: ", unzip_directory if @verbose

      Zip::File.open(ipa_path) do |zip_file|
        zip_file.each do |entry|
          next if entry.name.start_with?("__MACOSX/")

          puts "Extracting #{entry.name}" if @verbose
          entry.extract(File.join(unzip_directory, entry.name))
        end
      end

      unzip_directory
    end

    def get_file_sha256(file_path)
      digest = Digest::SHA256.new
      File.open(file_path, "rb") do |file|
        buffer = ""
        digest.update(buffer) while file.read(4096, buffer)
      end

      digest.hexdigest
    end

    def get_strings_from_binary(binary_path)
      strings = `strings "#{binary_path}"`.split("\n")
      strings.map(&:strip)
    end

    def compare_ipa_strings(save_common_strings: false)
      dir1 = unzip_ipa(@ipa_path1)
      dir2 = unzip_ipa(@ipa_path2)

      strings1 = get_strings_from_directory(dir1)
      strings2 = get_strings_from_directory(dir2)

      common_strings = strings1 & strings2
      different_strings = (strings1 | strings2) - common_strings

      save_strings_to_file(common_strings, "common_strings.txt") if save_common_strings

      duplicates = find_files_with_same_sha256(dir1, dir2)

      {
        common_strings: common_strings,
        different_strings: different_strings,
        same_sha256: duplicates
      }
    ensure
      FileUtils.remove_entry(dir1, true)
      FileUtils.remove_entry(dir2, true)
    end

    def find_files_with_same_sha256(dir1, dir2)
      files_dir1 = Dir.glob("#{dir1}/**/*")
      files_dir2 = Dir.glob("#{dir2}/**/*")

      hash_files_dir1 = compute_hash_files(files_dir1)
      hash_files_dir2 = compute_hash_files(files_dir2)

      common_files_hashes = hash_files_dir1.keys & hash_files_dir2.keys

      common_files_hashes.to_h do |sha256|
        files = hash_files_dir1[sha256] + hash_files_dir2[sha256]

        files.map! { |file| file.delete_prefix(dir1) }
        files.map! { |file| file.delete_prefix(dir2) }
        [sha256, files]
      end
    end

    def compute_hash_files(files)
      hash_files = {}

      files.each do |file|
        next unless File.file?(file)

        hash = Digest::SHA256.file(file).hexdigest
        hash_files[hash] ||= []
        hash_files[hash] << file
      end

      hash_files
    end

    private

    def get_strings_from_directory(directory)
      strings = []
      Dir.glob(File.join(directory, "**/*")).each do |file_path|
        next unless File.file?(file_path)

        strings += get_strings_from_binary(file_path)
      end
      strings
    end

    def save_strings_to_file(strings, file_path)
      File.open(file_path, "w") do |file|
        strings.each do |string|
          file.puts(string)
        end
      end
    end
  end
end
