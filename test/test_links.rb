require 'webapp_test'
class LinksTest < WebAppTest

  def setup
    super
    @visited = {}
  end

  def internal?(link)
    link && !(link =~ /^(https?|mailto|ftp):/)
  end

  def test_links
    visit('/sitemap.xml')
    @pages = all("loc").to_a.each do |elm|
      page = (elm.text.match %r{http://www.classandjazz.be(/.*)})[1]
      do_visit(page) do 
        all("a").
          select{|elm| internal?(elm["href"])}.
          each do |elm|
            do_visit(elm["href"])
          end
      end
    end
  end

  def do_visit(url)
    @visited[url] ||= begin
      puts "Visiting #{url}"
      visit(url)
      assert_equal 200, page.status_code, "#{url} should respond"
      yield if block_given?
      true
    end
  end

end
