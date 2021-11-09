Encoding.default_external = Encoding::UTF_8 if RUBY_VERSION > "1.9"

# set development environment and launch dependencies
ENV["RACK_ENV"] = "production"
require 'bundler'
Bundler.setup(:production)

# chdir to root now
Dir.chdir(root = File.expand_path('../../',__FILE__)) do
  # update loadpath and load project
  $: << File.join(root,"lib")
  require 'classandjazz'

  run ClassAndJazz::WebApp
end
