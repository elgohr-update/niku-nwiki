# -*- coding: utf-8 -*-
require 'erb'
require 'rss'

module Nwiki
  module Frontend
    class App
      def initialize git_repo_path
        @builder = Rack::Builder.new {
          map '/' do
            run ->(req) {
              [
                200,
                { "Content-Type" => "text/html; charset=#{Nwiki::Core::Wiki.repo_filename_encoding}" },
                ['ヽ（´・肉・｀）ノログ']
              ]
            }
          end
          map '/articles.xml' do
            run Feed.new git_repo_path, articles_path: '/articles'
          end
          map '/articles' do
            run Html.new git_repo_path
          end
        }
      end

      def call env
        @builder.call env
      end
    end

    class Feed
      attr_reader :articles_path

      def initialize git_repo_path, opts = {}
        @wiki = Nwiki::Core::Wiki.new git_repo_path
        raise unless @wiki.exist?
        @articles_path = opts[:articles_path] || ''
      end

      def call env
        [
          200,
          { 'Content-Type' => "application/atom+xml; charset=#{Nwiki::Core::Wiki.repo_filename_encoding}" },
          [
            RSS::Maker.make('atom') { |maker|
              maker.channel.title = @wiki.title
              maker.channel.description = @wiki.subtitle
              maker.channel.link = Rack::Request.new(env).url

              maker.channel.author = @wiki.author
              maker.channel.date = Time.parse('2014-02-06')
              maker.channel.id = Rack::Request.new(env).url

              maker.items.do_sort = true
              maker.items.max_size = 50

              log = @wiki.access.repo.log
              log.each do |commit|
                date = commit.date
                commit.show.each do |diff|
                  next unless diff.new_file

                  path = Nwiki::Core::Wiki.canonicalize_path(diff.b_path)
                  path.gsub!(/\.org$/, '')

                  maker.items.new_item do |item|
                    item.link = Rack::Request.new(env).url.gsub(Regexp.new(Rack::Request.new(env).fullpath), "#{articles_path}/#{path}")
                    item.title = File.basename(path)
                    item.date = date
                  end
                end
              end
            }.to_s
          ]
        ]
      end
    end

    class Html
      def initialize git_repo_path
        @wiki = Nwiki::Core::Wiki.new git_repo_path
        raise unless @wiki.exist?
      end

      def call env
        path_info = env["PATH_INFO"]
        page = @wiki.find path_info
        case page
        when Core::Page, Core::Directory
          [200, {"Content-Type" => "text/html; charset=#{page.encoding}"}, [html(page)]]
        when Core::File
          [200, {"Content-Type" => page.content_type}, [page.data]]
        else
          [404, {"Content-Type" => "text/plane"}, ["not found."]]
        end
      end

      def html page
        erb = ERB.new <<EOS
<!DOCTYPE HTML>
<html>
<head>
  <title><%= page.title %> - <%= @wiki.title %></title>
  <link rel="alternate" type="application/atom+xml" title="ATOM Feed" href="/articles.xml">
  <link href="/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
  <script src="/bootstrap/js/bootstrap.min.js"></script>
</head>
<body>
  <div class="container">
    <div class="row">
      <div class="span12">
        <h1><%= @wiki.title %></h1>
        <h2><%= @wiki.subtitle %></h2>
        <%= page.to_html %>
      </div>
    </div>
  </div>
</body>
</html>
EOS
        erb.result(binding).force_encoding(page.encoding)
      end
    end
  end
end
