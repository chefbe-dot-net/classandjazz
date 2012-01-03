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
    @removals = @rewriting["removal"]
  end

  def test_redirects
    @redirects.each do |h|
      old, new = h.values_at("old", "new")
      ["en", "fr", "nl"].each do |lang|
        get "/#{lang}#{old}"
        assert_equal 301, last_response.status, "URL #{old} is redirected permanently"

        get (red = last_response.headers["Location"])
        exp = @removals.find{|r| red.index(r)} ? 410 : 200
        assert_equal exp, last_response.status, "URL #{new} is a valid new location"
      end
    end
  end

  def test_removals
    @removals.each do |url|
      get url
      assert_equal 410, last_response.status, "URL #{url} is marked as removed"
    end
  end

end
