module Nwiki
  module Utils
    def self.page_title path
      path.empty? ? '' : "#{path.gsub(/\.org$/, '').gsub(/^\//, '')} - "
    end

    def self.orgfile? path
      ::File.extname(path) == ".org"
    end

    def strip_org path
      path.gsub(/\.org$/) { '' }
    end
  end
end