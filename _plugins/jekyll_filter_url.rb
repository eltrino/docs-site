require 'iso-639'

module Jekyll
  module UrlFilter
    def doc_url(input)
      relative = input.scan(/\w{2}\/[\w0-9\.]+\/(.*)/)[0][0]
      return relative
    end

    def version_url(input)
      version = input.scan(/\w{2}\/([\w0-9\.]+)\/.*/)[0][0]
      return version
    end

    def language_url(input)
      language = input.scan(/(\w{2})\/[\w0-9\.]+\/.*/)[0][0]
      return language
    end
  end
end

Liquid::Template.register_filter(Jekyll::UrlFilter)
