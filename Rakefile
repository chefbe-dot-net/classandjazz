$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

desc %q{Regenerates CSS stylesheet}
task :css do
  Dir.chdir(File.expand_path('../public/_assets/css', __FILE__)) do
    `lessc style.less > style.css`
  end
end

desc %q{Run the website locally}
task :development do
  exec "ruby scripts/run.rb development"
end

desc %q{Run all client tests}
task :test do
  exec "bundle exec ruby -Ilib -Itest test/runall.rb"
end

desc %q{Build docker image and push it to q8s}
task :q8sbuild do
  exec "docker build -t q8s.quadrabee.com/chefbe/classandjazz . && \
        docker push q8s.quadrabee.com/chefbe/classandjazz"
end