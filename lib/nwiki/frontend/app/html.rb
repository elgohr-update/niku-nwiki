require 'erb'

module Nwiki
  module Frontend
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
        <h1><a href="/articles/"><%= @wiki.title %></a></h1>
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
