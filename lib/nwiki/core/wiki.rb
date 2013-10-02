require 'rack'
require 'org-ruby'

module Nwiki
  module Core
    class Wiki
      def self.repo_filename_encoding
        Encoding::UTF_8
      end

      def self.parser
        Orgmode::Parser
      end

      def self.canonicalize_path path
        unescaped_path = URI.unescape(path).force_encoding(repo_filename_encoding)
        unescaped_path.sub(/^\//, '')
      end

      def initialize path
        @path = path
        @access = GitAccess.new(path)
      end

      def find path
        canonicalized_path = self.class.canonicalize_path path
        if canonicalized_path == ''
          find_directory(canonicalized_path)
        else
          find_page_or_file(canonicalized_path)
        end
      end

      def find_page_or_file path
        entry = @access.find_file do |entry_path|
          path == entry_path.sub(/\.org$/){ '' }
        end
        return nil unless entry
        if entry.path =~ /\.org$/
          path = entry.path.sub(/\.org$/){ '' }
          Page.new(path, entry.text, self.class.parser)
        else
          File.new(entry.path, entry.content)
        end
      end

      def find_directory path
        files = @access.all_files
        Directory.encoding = self.class.repo_filename_encoding
        Directory.new(path, files.map(&:path))
      end

      def title
        @access.title
      end

      def subtitle
        @access.subtitle
      end

      def author
        @access.author
      end

      def log
        @access.log
      end
    end
  end
end
