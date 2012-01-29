require 'webapp_test'
class ClassAndJazzTest < WebAppTest
  include ClassAndJazz

  def setup
    @google = "http://google.com"
  end
  
  def test_internal
    assert !internal?(@google)
    assert internal?('internal')
  end
  
  def test_external
    assert external?(@google)
    assert !external?('internal')
  end
  
  def test_makelink_recognizes_external_links
    expected = %Q{<a target="_blank" href="#{@google}">google</a>}
    assert_equal expected, makelink(@google, 'google')
  end

  def test_makelink_recognizes_internal_links
    expected = %Q{<a href="internal">label</a>}
    assert_equal expected, makelink('internal', 'label')
  end

  def test_makelink_supports_no_label
    expected = %Q{<a href="internal">internal</a>}
    assert_equal expected, makelink('internal')
  end
  
  def def test_makelink_supports_nil_labels
    expected = %Q{<a href="internal">internal</a>}
    assert_equal expected, makelink('internal', nil)
  end

end