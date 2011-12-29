require 'webapp_test'
class LinksTest < WebAppTest

  def setup
    super
    visit('/sitemap.xml')
    @pages = all("loc").map do |elm|
      elm.text =~ %r{http://www.classandjazz.be(/.*)}
      $1
    end
    @visited = {}
  end

  def internal?(link)
    link && !(link =~ /^(https?|mailto|ftp):/)
  end

  def test_links
    @pages.each do |p|
#      do_visit(p) do
#        all("img").each do |elm|
#          do_visit(elm["src"]) if internal?(elm["src"])
#        end
#      end
      do_visit(p) do
        all("a").each do |elm|
          do_visit(elm["href"]) if internal?(elm["href"])
        end
      end
    end
  end

  def do_visit(url)
    puts "On #{url}"
    @visited[url] ||= begin
      visit(url)
      assert_equal 200, page.status_code, "#{url} should respond"
      yield if block_given?
      true
    end
  end

end
