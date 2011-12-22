require 'webapp_test'
class LangTest < WebAppTest

  def test_default_language
    visit('/')
    assert_equal "nl", first("html")["lang"]
  end

  def test_english
    visit('/?lang=en')
    assert_equal "en", first("html")["lang"]
  end

  def test_unexisting
    visit('/nosuchone')
    assert_equal 404, page.status_code
  end

end
