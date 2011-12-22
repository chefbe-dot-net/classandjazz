require 'webapp_test'
class LinksTest < WebAppTest

  def setup
    visit('/sitemap.xml')
    @pages = all("loc").map do |elm|
      elm.text =~ %r{http://www.classandjazz.be(/.*)}
      $1
    end
    @visited = {}
  end

  def internal?(link)
    link && !(link =~ /^http:/)
  end

  def test_links
    @pages.each do |p|
      do_visit(p) do
        all("img").each do |elm|
          do_visit(elm["src"]) if internal?(elm["src"])
        end
      end
      do_visit(p) do
        all("a").each do |elm|
          do_visit(elm["href"]) if internal?(elm["href"])
        end
      end
    end
  end

  def do_visit(url)
    @visited[url] ||= begin
      visit(url)
      assert_equal 200, page.status_code
      yield if block_given?
      true
    end
  end

end
