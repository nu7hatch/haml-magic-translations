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

def render(text, options = {}, &block)
  scope  = options.delete(:scope)  || Object.new
  locals = options.delete(:locals) || {}
  Haml::Engine.new(text, options).to_html(scope, locals, &block)
end
