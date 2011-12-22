require 'webapp_test'
class GoogleFilesTest < WebAppTest

  def test_robots_txt
    visit('/robots.txt')
    assert_equal 200, page.status_code
  end

  def test_sitemap
    visit('/sitemap.xml')
    assert_equal 200, page.status_code
    all("loc").to_a.each do |elm|
      elm.text =~ %r{http://www.classandjazz.be(/.*)}
      visit($1)
      assert_equal 200, page.status_code
    end
  end

end
