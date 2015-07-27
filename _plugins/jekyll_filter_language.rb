require 'iso-639'

module Jekyll
  module LanguageFilter
    def english_name(input)
      entry = ISO_639.find(input)
      if entry
        return entry.english_name
      end
      return input
    end
  end
end

Liquid::Template.register_filter(Jekyll::LanguageFilter)
