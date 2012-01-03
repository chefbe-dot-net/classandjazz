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
    @aliases = @rewriting["alias"]
  end

  def expected_status(x)
    if @removals.include?(x)
      410
    elsif @redirects.find{|h| h["old"] == x}
      301
    elsif @aliases.find{|h| h["from"] == x}
      303
    else
      200
    end
  end

  def internal?(link)
    link && !(link =~ /^(https?|mailto|ftp):/)
  end

  def test_redirects
    @redirects.each do |h|
      old, new = h.values_at("old", "new")
      puts "Checking rewriting of #{old} -> #{new}"
      ["en", "fr", "nl"].each do |lang|
        get "/#{lang}#{old}"
        assert_equal 301, 
                     last_response.status, 
                     "URL #{old} is redirected permanently"

        if internal?(new)
          get last_response.headers["Location"]
          assert_equal expected_status(new), 
                       last_response.status, 
                       "URL #{new} is a valid new location"
        end
      end
    end
  end

  def test_removals
    @removals.each do |url|
      get url
      assert_equal 410, 
                   last_response.status, 
                   "URL #{url} is marked as removed"
    end
  end

end
