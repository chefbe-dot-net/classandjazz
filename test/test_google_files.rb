require 'webapp_test'
class GoogleFilesTest < WebAppTest

  def test_robots_txt
    visit('/robots.txt')
    assert_equal 200, page.status_code
  end

  def test_sitemap
    visit('/sitemap.xml')
    assert_equal 200, page.status_code
  end

  def test_verification_fie
    visit('/googleec799723efa513b7.html')
    assert_equal 200, page.status_code
  end

  def test_verification_fie
    visit('/google4efc1a3f6ff86289.html')
    assert_equal 200, page.status_code
  end

end
