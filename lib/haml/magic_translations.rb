require 'haml'
require 'haml/template'

require 'i18n'
require 'i18n/backend/gettext'
require 'i18n/gettext/helpers'

##
# This plugin provides "magical translations" in your .haml files. What does it
# mean? It's mean that all your raw texts in templates will be automatically
# translated by Gettext backend from I18n. No more complicated translation keys
# and ugly translation methods in views. Now you can only write in your language,
# nothing more. At the end of your work you can easy find all phrases to translate
# and generate .po files for it. This type of files are also more readable and 
# easier to translate, thanks to it you save your time with translations. 
#
# === Examples
#
# Now you can write what you want, and at the end of work you 
# will easy found all phrases to translate. Check out following example:
# 
#   %p This is my simple dummy text.
#   %p And more lorem ipsum...
#   %p= link_to _("This will be also translated"), "#"
#   
# Those translations are allso allowing you to use standard Haml interpolation. 
# You can easy write: 
#   
#   %p This is my text with #{"interpolation".upcase}... Great, isn't it?
#   
# And text from codes above will be stored in .po files as:
# 
#   # File test1.haml, line 1
#   msgid "This is my simple dummy text"
#   msgstr "This is my dummy translation of dummy text"
#   
#   # File test2.haml, line 1
#   msgid "This is my text with %s... Great, isn't it?"
#   msgstr "Next one %s translation!"
#   
# Generator for .po files also includes information where your phrases are placed
# in filesystem. Thanks to it you don't forget about any even small word to 
# translate. 
# 
module Haml::MagicTranslations
  # Overriden function that parses Haml tags. Injects gettext call for all plain
  # text lines.
  def parse_tag(line)
    tag_name, attributes, attributes_hashes, object_ref, nuke_outer_whitespace,
      nuke_inner_whitespace, action, value, last_line = super(line)
    
    magic_translations = self.options[:magic_translations]
    magic_translations = Haml::Template.options[:magic_translations] if magic_translations.nil?
    
    if magic_translations
      unless action && action != '!' || action == '!' && value[0] == '=' || value.empty?
        value, interpolation_arguments = prepare_i18n_interpolation(value)
        value = "\#{_('#{value.gsub(/'/, "\\\\'")}') % #{interpolation_arguments}\}\n"
      end
    end
    [tag_name, attributes, attributes_hashes, object_ref, nuke_outer_whitespace,
       nuke_inner_whitespace, action, value, last_line]
  end
  
  # Magical translations will be also used for plain text. 
  def push_plain(text, options = {})
    if block_opened?
      raise SyntaxError.new("Illegal nesting: nesting within plain text is illegal.", @next_line.index)
    end

    options[:magic_translations] = self.options[:magic_translations] if options[:magic_translations].nil?
    options[:magic_translations] = Haml::Template.options[:magic_translations] if options[:magic_translations].nil?
    
    if options[:magic_translations]
      value, interpolation_arguments = prepare_i18n_interpolation(text, 
        :escape_html => options[:escape_html])
      value = "_('#{value.gsub(/'/, "\\\\'")}') % #{interpolation_arguments}\n"
      push_script(value, :escape_html => false)
    else
      if contains_interpolation?(text)
        options[:escape_html] = self.options[:escape_html] if options[:escape_html].nil?
        push_script(
          unescape_interpolation(text, :escape_html => options[:escape_html]),
          :escape_html => false)
      else
        push_text text
      end
    end
  end
  
  # It discovers all fragments of code embeded in text and replacing with 
  # simple string interpolation parameters. 
  # 
  # ==== Example: 
  #
  # Following line...
  # 
  #   %p This is some #{'Interpolated'.upcase'} text
  #
  # ... will be translated to:
  #
  #   [ "This is some %s text", "['Interpolated'.upcase]" ]
  #
  def prepare_i18n_interpolation(str, opts = {})
    args = []
    res  = ''
    str = str.
      gsub(/\n/, '\n').
      gsub(/\r/, '\r').
      gsub(/\#/, '\#').
      gsub(/\"/, '\"').
      gsub(/\\/, '\\\\')
      
    rest = Haml::Shared.handle_interpolation '"' + str + '"' do |scan|
      escapes = (scan[2].size - 1) / 2
      res << scan.matched[0...-3 - escapes]
      if escapes % 2 == 1
        res << '#{'
      else
        content = eval('"' + balance(scan, ?{, ?}, 1)[0][0...-1] + '"')
        content = "Haml::Helpers.html_escape(#{content.to_s})" if opts[:escape_html]
        args << content
        res  << '%s'
      end
    end
    value = res+rest.gsub(/\\(.)/, '\1').chomp
    value = value[1..-2] unless value.blank?
    args  = "[#{args.join(', ')}]"
    [value, args]
  end
end

I18n::Backend::Simple.send(:include, I18n::Backend::Gettext)
Haml::Engine.send(:include, Haml::MagicTranslations)
Haml::Helpers.send(:include, I18n::Gettext::Helpers)
Haml::Template.options[:magic_translations] = true

