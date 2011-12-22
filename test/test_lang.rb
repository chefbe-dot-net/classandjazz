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

  def test_french
    visit('/?lang=fr')
    assert_equal "fr", first("html")["lang"]
  end

  def test_dutch
    visit('/?lang=nl')
    assert_equal "nl", first("html")["lang"]
  end

end
