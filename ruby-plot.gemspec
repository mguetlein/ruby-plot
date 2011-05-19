# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-plot}
  s.version = "0.4.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Vorgrimmler", "Martin G\303\274tlein"]
  s.date = %q{2011-05-19}
  s.description = %q{}
  s.email = %q{vorgrimmlerdavid@gmx.de}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "README",
    "Rakefile",
    "VERSION",
    "lib/plot_bars.rb",
    "lib/plot_lines.rb",
    "lib/plot_points.rb",
    "lib/ruby-plot.rb"
  ]
  s.homepage = %q{http://github.com/davor/ruby-plot}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.2}
  s.summary = %q{gnuplot wrapper for ruby, especially for plotting roc curves into svg files}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<gnuplot>, [">= 0"])
    else
      s.add_dependency(%q<gnuplot>, [">= 0"])
    end
  else
    s.add_dependency(%q<gnuplot>, [">= 0"])
  end
end

