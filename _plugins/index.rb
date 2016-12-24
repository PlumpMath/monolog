module Jekyll
  class IndexPage < Page
    def initialize(site, base, pages)
      @site = site
      @base = base
      @dir = ""
      @name = 'index.html'
      @content = 'a machine made me ' + `date`
      self.process(@name)
      self.data = {'layout' => 'index'}
      @pages = pages
    end
  end

  class IndexPageGenerator < Generator
    safe true

    def generate(site)
      site.pages << IndexPage.new(site, site.source, site.pages.reject { |p| p.data['layout'] })
    end
  end
end