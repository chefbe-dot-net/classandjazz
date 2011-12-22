Dir.chdir("config") do
  instance_eval File.read("production.ru")
end
