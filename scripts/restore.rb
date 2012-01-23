#!/usr/bin/env ruby
class Restore

  attr_reader :root, :logio

  def initialize(root)
    @root = root
  end

  def say(what)
    puts what
    logio << what rescue nil
  end

  def confirmed?(message)
    begin
      say(message)
      c = $stdin.gets
    end until c =~ /y(es)?|n(o)?/
    c =~ /y(es)?/
  end

  def shell(command)
    say "#{command}\n"
    IO.popen(command, :err => [:child, :out]) do |io|
      while s = io.gets
        say("\t#{s}")
      end
    end
    say "done. (#{$?})\n\n"
  end

  def run!
    log_file = File.join(root, 'logs', 'restore.log')
    File.open(log_file, 'w') do |log|
      @logio = log
      restore!
    end
  ensure
    say("Done. Press enter.")
    $stdin.gets
  end

  def restore!
    Dir.chdir(root) do
      if confirmed?("All local changes will be lost. Are you sure [y/n]?\n")
        shell "git remote update"
        shell "git reset --hard origin/master"
        shell "bundle install --no-color"
      else
        say("cancelled.\n")
      end
    end
  rescue Exception => ex
    say("something goes really bad here:")
    say("\t#{ex.message}\n\t")
    say(ex.backtrace.join("\n\t"))
  end

end # class Restore

if $0 == __FILE__
  root = File.expand_path('../..', __FILE__)
  Restore.new(root).run!
end
