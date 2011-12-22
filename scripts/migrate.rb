#!/usr/bin/env ruby
dir = File.dirname(File.dirname(__FILE__))
Dir["#{dir}/**/index.yml"].each do |file|
  begin
    before = File.read(file)
    if before =~ rx
      puts "Rewriting #{file}"
      File.open(file, 'w') do |io|
        io << before.gsub(rx, to)
      end
    end
  rescue => ex
    puts "Skipping #{file}: #{ex.message}"
  end
end
