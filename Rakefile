require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "ruby-plot"
    gem.summary = %Q{gnuplot wrapper for ruby, especially for plotting roc curves into svg files}
    gem.description = %Q{}
    gem.email = "vorgrimmlerdavid@gmx.de"
    gem.homepage = "http://github.com/davor/ruby-plot"
    gem.authors = ["David Vorgrimmler", "Martin Gütlein"]
		['gnuplot'].each do |dep|
		  gem.add_dependency dep
		end
		gem.files =  FileList["[A-Z]*", "{bin,generators,lib,test}/**/*"]
		gem.files.include %w(lib/ruby-plot.rb)
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
	Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ruby-plot #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
