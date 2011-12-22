#!/usr/bin/env ruby

def change(x)
  puts x
  x
end

def link(link)
  case link
    when "/", /^http/, /^mailto:/
      link
    else
      "/#{link}/"
  end
end

dir = File.dirname(File.dirname(__FILE__))
Dir["#{dir}/**/index.yml"].each do |file|
  begin
    before = File.read(file)
    before.gsub!(/@\{(.*?)\}\[(.*?)\]/) do |match|
      "@{#{link($2)}}{#{$1}}"
    end
    before.gsub!(/\{(.*?)\}\[(.*?)\]/) do |match|
      "@{#{link($2)}}{#{$1}}"
    end
    before.gsub!(/===/) do |match|
      "###"
    end
    before.gsub!(/==/) do |match|
      "##"
    end

    puts "Rewriting #{file}"
    File.open(file, 'w') do |io|
      io << before
    end
  rescue => ex
    puts "Skipping #{file}: #{ex.message}"
  end
end
