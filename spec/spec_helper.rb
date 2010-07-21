ENV["RAILS_ENV"] = "test"
require 'rubygems'
require 'spec'

$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'action_controller'
require 'action_view'

require 'haml/magic_translations'

Haml::Template.options[:ugly] = false
Haml::Template.options[:format] = :xhtml

I18n::Backend::Simple.send(:include, I18n::Backend::Gettext)
I18n.load_path += Dir[File.join(File.dirname(__FILE__), "locales/*.{po}")]

