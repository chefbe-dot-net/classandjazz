require 'logger'
class Script
  
  attr_reader :root, :logio

  def initialize
    @root = File.expand_path("../..", __FILE__)
  end

  ######################################################### User interactions

  def confirmed?(message)
    begin
      say(message)
      c = $stdin.gets
    end until c =~ /y(es)?|n(o)?/
    c =~ /y(es)?/
  end

  ######################################################### Shell & spawn

  def shell(command)
    say "#{command}\n"
    IO.popen(command, :err => [:child, :out]) do |io|
      while s = io.gets
        say("\t#{s}")
      end
    end
    say "done. (#{$?})\n\n"
  end

  ######################################################### Logging
  
  def log_file
    File.join(root, 'logs', "#{File.basename($0, '.rb')}.log")
  end
  
  def logger
    @logger ||= Logger.new(log_file)
  end
  
  def log(message, severity)
    puts message
    logger.send(severity, message.strip)
    yield if block_given?
  end
  def debug(message, &block); log(message, :debug, &block); end
  def info(message, &block);  log(message, :info,  &block); end
  def warn(message, &block);  log(message, :warn,  &block); end
  def error(message, &block); log(message, :error, &block); end
  def fatal(message, &block); log(message, :fatal, &block); end
  alias :say :info

  ######################################################### Execution
  
  def parse_options(argv)
    require 'optparse'
    opts = OptionParser.new
    options(opts)
    opts.parse!(argv)
  end
  
  def options(opt)
  end
  
  def run!(argv)
    Dir.chdir(root) do
      argv = parse_options(argv)
      execute(argv)
    end
  rescue => ex
    say "Something goes bad here: #{ex.message}"
    say ex.backtrace.join("\n")
  ensure
    say("Done. Press enter.")
    $stdin.gets
  end

end