require 'redcarpet'
require 'yaml'

module Jekyll
  class RenderNavigationTag < Liquid::Tag

    def render(context)
      @site = context.registers[:site]
      navigations = @site.config['navigations']

      @page = context.registers[:page]
      @language, @version = @page['path'].scan(/(\w{2})\/([\w0-9\.]+)\/.*/)[0]

      html = ''
      navigations[@language][@version].each{ |child| html += element child }
      return html
    end

    def element(data, file = nil)
      html = ''
      if data.kind_of? String
        page = get_page(data)
        page['url'].gsub!(/index\.html$/, '')
        html += '<li><a href="' + page['url'] +  '">' + page['title'] + '</a>'
        if @page['url'] == page['url']
          html += Redcarpet::Markdown.new(Redcarpet::Render::HTML_TOC.new(nesting_level: 2)).render(@page['content'])
        end
        html += '</li>'
      elsif data.kind_of? Hash
        data.each{ |file, child| html += element child, file }
      else
        if file
          page = get_page(file)
          page['url'].gsub!(/index\.html$/, '')
          html += '<li><a href="' + page['url']  +  '">' + page['title'] + '</a>'
        end
        html += '<ul>'
        data.each{ |child| html += element child }
        html += '</ul></li>'
      end
      return html
    end

    def get_page(file)
      for page in @site.pages
        language, version, path = page['path'].scan(/(\w{2})\/([\w0-9\.]+)\/(.*)/)[0]
        if @language != language || @version != version || path != file
          next
        end
        return page
      end
      raise sprintf("Navigation has link to non existing page (%s)", file)
    end

  end
end

Liquid::Template.register_tag('navigation', Jekyll::RenderNavigationTag)
