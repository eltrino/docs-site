module Jekyll
  class GeneratorVersions < Jekyll::Generator
    def generate(site)

      versions = []
      languages = []
      for page in site.pages
        next if page['exclude_from_search']

        language, version = page['path'].scan(/(\w{2})\/([\w0-9\.]+)\/.*/)[0]
        versions << version unless versions.include?(version)
        languages << language unless languages.include?(language)
      end

      navigations = {}
      for language in languages
        for version in versions
          if !Dir.exist?(sprintf("%s/%s", language, version))
            next
          end
          file = sprintf("%s/%s/_navigation.yml", language, version)
          if !File.exist?(file)
            raise sprintf("Version %s/%s does not have _navigation.yml file", language, version)
          end
          navigations[language] = {} unless navigations[language]
          navigations[language][version] = YAML.load_file(file)
        end
      end

      site.config['navigations'] = navigations
      site.config['versions'] = versions
      site.config['languages'] = languages
    end
  end
end
