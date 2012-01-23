#!/usr/bin/env ruby
require File.expand_path('../script', __FILE__)
class Restore < Script

  def _run!(argv)
    restore!
  end

  def restore!
    if confirmed?("All local changes will be lost. Are you sure [y/n]?\n")
      shell "git remote update"
      shell "git reset --hard origin/master"
      shell "bundle install --no-color"
    else
      say("cancelled.\n")
    end
  rescue Exception => ex
    say("something goes really bad here:")
    say("\t#{ex.message}\n\t")
    say(ex.backtrace.join("\n\t"))
  end

end # class Restore

if $0 == __FILE__
  Restore.new.run!(ARGV)
end
