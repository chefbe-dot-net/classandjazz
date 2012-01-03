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
    @oldies = @rewriting["v1"]
    @redirects = @rewriting["redirect"]
    @removed = @rewriting["removed"]
  end

  def expected_status(x)
    if @removed.include?(x)
      410
    elsif h = @redirects.find{|h| h["from"] == x}
      h["status"] || 301
    elsif h = @oldies.find{|h| h["old"] == x}
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
      old, new, exp_status = h.values_at("from", "to", "status")
      puts "Checking rewriting of #{old} -> #{new}"

      get old
      assert_equal exp_status || 301, 
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

  def test_oldies
    @oldies.each do |h|
      old, new, exp_status = h.values_at("old", "new", "status")
      puts "Checking v1 of #{old} -> #{new}"
      ["en", "fr", "nl"].each do |lang|
        get "/#{lang}#{old}"
        assert_equal exp_status || 301, 
                     last_response.status, 
                     "URL #{old} is redirected permanently"

        get last_response.headers["Location"]
        assert_equal expected_status(new), 
                     last_response.status, 
                     "URL #{new} is a valid new location"
      end
    end
  end

end
