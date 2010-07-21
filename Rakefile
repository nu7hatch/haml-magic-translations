require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "haml-magic-translations"
    gem.summary = "Provides automaticaly translations in haml templates"
    gem.description = <<-DESCR
This plugin provides "magical translations" in your .haml files. What does it
mean? It's mean that all your raw texts in templates will be automatically
translated by GetText, FastGettext or Gettext backend from I18n. No more 
complicated translation keys and ugly translation methods in views. Now you can
only write in your language, nothing more. At the end of your work you can easy 
find all phrases to translate and generate .po files for it. This type of files 
are also more readable and easier to translate, thanks to it you save your 
time with translations.
    DESCR
    gem.email = "kriss.kowalik@gmail.com"
    gem.homepage = "http://github.com/kriss/haml-magic-translations"
    gem.authors = ["Kriss Kowalik"]
    gem.add_development_dependency "haml", ">= 3.0.0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
require 'rake/rdoctask'

desc 'Default: run specs.'
task :default => :spec

desc 'Run the specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = Dir['spec/**/*_spec.rb']
  t.spec_opts  = %w(-fs --color)
end

namespace :spec do
  desc "Run all specs with RCov"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec,/Users/']
  end
end

desc 'Generate documentation for the simple_navigation plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SimpleNavigation'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
