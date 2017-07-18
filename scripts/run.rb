#!/usr/bin/env ruby
require File.expand_path('../script', __FILE__)
class Run < Script
  
  attr_accessor :mode,
                :refresh_repo,
                :open_browser,
                :try,
                :max
  
  # Install the options
  def options(opt)
    self.refresh_repo = true
    opt.on('--[no-]refresh', "Issues a 'git remote update' first?") do |value|
      self.refresh_repo = value
    end
    self.open_browser = true
    opt.on('--[no-]browser', "Open the browser automatically?") do |value|
      self.open_browser = value
    end
    self.try = 0
    self.max = 500
    opt.on('--max=MAX', Integer, "Number of connection attempts") do |value|
      self.max = Integer(value)
    end
  end
  
  # Tries to access the website
  def wait_and_open
    info "Attempting to connect to the web site..."
    Http.head "http://127.0.0.1:9292/"
  rescue Errno::ECONNREFUSED
    sleep(0.5)
    retry if (self.try += 1) < max
    info "Server not found, sorry."
    raise
  else
    Launchy.open("http://127.0.0.1:9292/")
  end
  
  def execute(argv)
    abort options.to_s unless argv.size <= 1
    self.mode = (argv.first || "development").to_sym

    config_ru = File.join(root, 'config', "#{mode}.ru")
    abort "Invalid mode #{mode}" unless File.exist?(config_ru)

    info "Refreshing repository info..." do
      shell "git remote update"
    end if refresh_repo

    info "Loading dependencies now" do
      require 'bundler'
      Bundler.setup(mode)
    end

    thinpid = nil
    info "Starting the web server..." do
      thinpid = spawn("bundle exec rackup config/development.ru")
    end

    info "Waiting for the server to start" do
      require 'launchy'
      require 'http'
      wait_and_open
    end if open_browser

  rescue => ex
    info "Lauching failed: #{ex.message}"
    info ex.backtrace.join("\n")
    Process.kill("SIGHUP", thinpid) if thinpid
  ensure
    Process.wait(thinpid) if thinpid
  end
  
  new.run!(ARGV) if $0 == __FILE__
end # class Run