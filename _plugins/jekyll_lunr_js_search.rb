require 'json'
require 'fileutils'

module Jekyll
  module LunrJsSearch
    class Indexer < Jekyll::Generator
      def initialize(config = {})
        super(config)

        lunr_config = {
          'excludes' => [],
          'strip_index_html' => false,
          'min_length' => 3,
          'stopwords' => 'stopwords.txt'
        }.merge!(config['lunr_search'] || {})

        @excludes = lunr_config['excludes']

        # if web host supports index.html as default doc, then optionally exclude it from the url
        @strip_index_html = lunr_config['strip_index_html']

        # stop word exclusion configuration
        @min_length = lunr_config['min_length']
        @stopwords_file = lunr_config['stopwords']
      end

      # Index all pages except pages matching any value in config['lunr_excludes'] or with date['exclude_from_search']
      # The main content from each page is extracted and saved to disk as json
      def generate(site)
        puts 'Running the search indexer...'

        # gather pages and posts
        items = pages_to_index(site)
        content_renderer = PageRenderer.new(site)
        indexes = {}

        items.each do |item|
          entry = SearchEntry.create(item, content_renderer)

          entry.strip_index_suffix_from_url! if @strip_index_html
          entry.strip_stopwords!(stopwords, @min_length) if File.exists?(@stopwords_file)

          path = item['path'].scan(/(\w{2})\/([\w0-9\.]+)\/.*/)[0].join('/')

          indexes[path] = [] unless indexes[path]
          indexes[path] << {
            :title => entry.title,
            :baseurl => site.config['baseurl'],
            :url => entry.url,
            :date => entry.date,
            :categories => entry.categories,
            :body => entry.body
          }

          puts 'Indexed ' << "#{entry.title} (#{entry.url})"
        end

        indexes.each do |path, index|
          json = JSON.generate({:entries => index})
          dest = File.join(site.dest, path)
          FileUtils.mkpath dest unless File.directory?(dest)

          # Search index
          filename = 'search.json'
          File.open(File.join(dest, filename), "w") do |file|
            file.write(json)
          end
          site.static_files << SearchIndexFile.new(site, site.dest, path, filename)
          # Search page
          site.pages << SearchLandingPage.new(site, site.source, path)
        end

      end

    private

      # load the stopwords file
      def stopwords
        @stopwords ||= IO.readlines(@stopwords_file).map { |l| l.strip }
      end

      def pages_to_index(site)
        items = []

        # deep copy pages
        site.pages.each {|page| items << page.dup }
        site.posts.docs.each {|post| items << post.dup }

        # only process files that will be converted to .html and only non excluded files
        items.select! {|i| i.output_ext == '.html' && ! @excludes.any? {|s| (i.url =~ Regexp.new(s)) != nil } }
        items.reject! {|i| i.data['exclude_from_search'] }

        items
      end
    end
  end
end
require 'nokogiri'

module Jekyll
  module LunrJsSearch
    class PageRenderer
      def initialize(site)
        @site = site
      end

      # render the item, parse the output and get all text inside <p> elements
      def render(item)
        layoutless = item.dup
        layoutless.data = layoutless.data.dup
        layoutless.data['layout'] = nil
        layoutless.render({}, @site.site_payload)
        doc = Nokogiri::HTML(layoutless.output)
        paragraphs = doc.search('//text()').map {|t| t.content }
        paragraphs = paragraphs.join(" ").gsub("\r", " ").gsub("\n", " ").gsub("\t", " ").gsub(/\s+/, " ")
      end
    end
  end
end
require 'nokogiri'

module Jekyll
  module LunrJsSearch
    class SearchEntry
      def self.create(page_or_post, renderer)
        return create_from_post(page_or_post, renderer) if page_or_post.is_a?(Jekyll::Post)
        return create_from_page(page_or_post, renderer) if page_or_post.is_a?(Jekyll::Page)
        raise 'Not supported'
      end

      def self.create_from_page(page, renderer)
        title, url = extract_title_and_url(page)
        body = renderer.render(page)
        date = nil
        categories = []

        SearchEntry.new(title, url, date, categories, body)
      end

      def self.create_from_post(post, renderer)
        title, url = extract_title_and_url(post)
        body = renderer.render(post)
        date = post.date
        categories = post.categories

        SearchEntry.new(title, url, date, categories, body)
      end

      def self.extract_title_and_url(item)
        data = item.to_liquid
        [ data['title'], data['url'] ]
      end

      attr_reader :title, :url, :date, :categories, :body

      def initialize(title, url, date, categories, body)
        @title, @url, @date, @categories, @body = title, url, date, categories, body
      end

      def strip_index_suffix_from_url!
        @url.gsub!(/index\.html$/, '')
      end

      # remove anything that is in the stop words list from the text to be indexed
      def strip_stopwords!(stopwords, min_length)
        @body = @body.split.delete_if() do |x|
          t = x.downcase.gsub(/[^a-z]/, '')
          t.length < min_length || stopwords.include?(t)
        end.join(' ')
      end
    end
  end
end
module Jekyll
  module LunrJsSearch
	  class SearchIndexFile < Jekyll::StaticFile
	    # Override write as the search.json index file has already been created
	    def write(dest)
	      true
	    end
	  end
    class SearchLandingPage < Jekyll::Page
      def initialize(site, base, dir)
      @site = site
      @base = base
      @dir = dir
      @name = 'search.html'
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'search.html')
    end
	  end
  end
end
module Jekyll
	module LunrJsSearch
  		VERSION = "0.1.1"
  	end
end
