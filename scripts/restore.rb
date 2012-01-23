#!/usr/bin/env ruby
require File.expand_path('../script', __FILE__)
class Restore < Script

  def execute(argv)
    if confirmed?("All local changes will be lost. Are you sure [y/n]?\n")
      shell "git remote update"
      shell "git reset --hard origin/master"
      shell "bundle install --no-color"
    else
      say("cancelled.\n")
    end
  rescue Exception => ex
    say "something goes really bad here:"
    say "\t#{ex.message}\n\t"
    say ex.backtrace.join("\n\t")
  end

  new.run!(ARGV) if $0 == __FILE__
end # class Restore