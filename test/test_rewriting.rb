require 'classandjazz'
require 'test/unit'
require 'rack/test'
class RewritingTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    ClassAndJazz::WebApp
  end

  def setup
    path = ClassAndJazz::WebApp::PUBLIC/"rewriting.yml"
    @rewriting = YAML.load(path.read)
    @redirects = @rewriting["redirect"]
    @removed = @rewriting["removed"]
  end

  def expected_status(x)
    if @removed.include?(x)
      410
    elsif h = @redirects.find{|h| h["from"] == x}
      h["status"] || 301
    else
      200
    end
  end

  def internal?(link)
    link && !(link =~ /^(https?|mailto|ftp):/)
  end

  def test_removals
    @removed.each do |url|
      puts "Checking removal of #{url}"
      get url
      assert_equal 410,
                   last_response.status,
                   "URL #{url} is marked as removed"
    end
  end

  def test_redirects
    @redirects.each do |h|
      old, new_s, exp_status = h.values_at("from", "to", "status")
      puts "Checking rewriting of #{old} -> #{new_s}"

      get old
      assert_equal exp_status || 301,
                   last_response.status,
                   "URL #{old} is redirected permanently"

      if internal?(new_s)
        get last_response.headers["Location"]
        assert_equal expected_status(new_s),
                     last_response.status,
                     "URL #{new_s} is a valid new location"
      end
    end
  end

end
