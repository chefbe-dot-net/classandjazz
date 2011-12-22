require 'webapp_test'
class StaticsTest < WebAppTest

  def test_root
    visit('/')
    assert_equal 200, page.status_code
  end

  def test_stylesheets
    visit('/')
    all("link", :rel => "stylesheet").each do |elm|
      visit(elm["href"])
      assert_equal 200, page.status_code
    end
  end

  def test_scripts
    visit('/')
    all("script").select{|elm| elm["src"]}.each do |elm|
      visit(elm["src"])
      assert_equal 200, page.status_code
    end
  end

end
