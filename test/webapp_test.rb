require 'classandjazz'
require 'test/unit'
require 'capybara'
require 'capybara/dsl'
class WebAppTest < Test::Unit::TestCase
  include Capybara::DSL

  attr_reader :theapp

  def setup
    ClassAndJazz::WebApp.set :environment, :test
    Capybara.app = ClassAndJazz::WebApp.new
  end

end
