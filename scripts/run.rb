# check arguments
if ARGV.length > 1 
  puts "Usage: ruby run.rb [mode]"
  exit(1)
end

# move to root directory
Dir.chdir(File.expand_path('../..', __FILE__)) do

  # check mode
  mode = (ARGV.first || "development").to_sym
  unless File.exists?("config/#{mode}.ru")
    puts "Invalid mode #{mode}, no such .ru file"
    exit(-1)
  end

  # load bundle now
  puts "Loading dependencies..."
  require 'bundler'
  Bundler.setup(:development)

  # Launch thin on #{mode}.ru
  puts "Starting the web server..."
  thinpid = spawn("thin -R config/#{mode}.ru start")

  # wait for it
  try, max = 0, 1000
  begin
    puts "Attempting to connect to the web site..."
    require 'http'
    Http.head "http://127.0.0.1:3000/"
  rescue 
    sleep(0.5)
    try += 1
    retry unless try > max
  end
  if try < max
    puts "Got it!!"
    require 'launchy'
    Launchy.open("http://127.0.0.1:3000/")
  else
    puts "Server not found, sorry."
    Process.kill("SIGHUP", thinpid)
  end

  Process.wait(thinpid)
end
