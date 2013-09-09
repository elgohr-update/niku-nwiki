# -*- coding: utf-8 -*-
require 'erb'

module Nwiki
  module Frontend
    class Top
      def initialize git_repo_path, opts = {}
        @wiki = Nwiki::Core::Wiki.new git_repo_path
      end

      def call env
        [
          200,
          { "Content-Type" => "text/html; charset=#{Nwiki::Core::Wiki.repo_filename_encoding}" },
          [html]
        ]
      end

      def html
        erb = ERB.new <<EOS
<!DOCTYPE HTML>
<html>
<head>
  <meta http-equiv="refresh" content="5;URL=http://niku.name/articles/">
  <title><%= @wiki.title %></title>
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
        <p>ここまだ何にも作ってないんす．<a href="./articles/">articles</a>以下が動いているのでそっちを見てね．5秒経つと自動で移動します．</p>
      </div>
    </div>
  </div>
</body>
</html>
EOS
        erb.result(binding).force_encoding(Nwiki::Core::Wiki.repo_filename_encoding)
      end
    end
  end
end