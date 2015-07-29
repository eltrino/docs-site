module Jekyll
  class RenderAnalyticsTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @text = text.strip
    end

    def render(context)
      site = context.registers[:site]
      if site.config["mode"] == 'development'
        return "<!-- analytics from provider '#{@text}' will be visible here in production -->"
      end

      template = File.read File.join Dir.pwd, '_includes', 'analytics', "#{@text}.html"
      (Liquid::Template.parse template).render site.site_payload
    end
  end
end

Liquid::Template.register_tag('analytics', Jekyll::RenderAnalyticsTag)