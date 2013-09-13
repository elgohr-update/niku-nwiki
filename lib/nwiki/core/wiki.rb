require 'rack'

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

      attr_reader :access

      def initialize path
        @path = path
        @access = GitAccess.new(path)
        @new_git_access = NewGitAccess.new(path)
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
        blob_entry = @access
          .tree('master')
          .find { |e| path == e.path.sub(/\.org$/){ '' } }
        return nil unless blob_entry
        byte_string = blob_entry.blob(@access.repo).data
        if blob_entry.name =~ /\.org$/
          byte_string.force_encoding(self.class.repo_filename_encoding)
          Page.new(::File.basename(blob_entry.name, '.org'), byte_string, self.class.parser)
        else
          File.new(blob_entry.name, byte_string)
        end
      end

      def find_directory path
        sha = @access.tree('master')
        Directory.encoding = self.class.repo_filename_encoding
        Directory.new(path, sha.map(&:path))
      end

      def title
        @new_git_access.title
      end

      def subtitle
        @new_git_access.subtitle
      end

      def author
        @new_git_access.author
      end

      def exist?
        @access.exist?
      end
    end
  end
end
