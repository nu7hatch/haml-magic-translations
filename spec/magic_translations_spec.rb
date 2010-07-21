require File.join(File.dirname(__FILE__), 'spec_helper.rb')

def render(text, options = {}, &block)
  scope  = options.delete(:scope)  || Object.new
  locals = options.delete(:locals) || {}
  Haml::Engine.new(text, options).to_html(scope, locals, &block)
end

describe 'Haml magic translations' do 

  it 'should allow to set :magic_translations option in Haml::Template' do
    Haml::Template.options.key?(:magic_translations).should be_true
  end

  it 'should translate text using existing locales' do 
    Haml::Template.options[:magic_translations] = true
    I18n.locale = :pl
    <<HTML.should == render(<<HAML)
<p>Magiczne tłumaczenie działa!</p>
<p>A tutaj razem z interpolacją, a to wszystko dzięki połączeniu I18n i GetText</p>
HTML
%p Magic translations works!
%p Here with interpolation, and everything thanks to \#{I18n.name} and \#{GetText.name}
HAML
  end

  it 'should leave text without changes when translation was not found' do
    Haml::Template.options[:magic_translations] = true
    I18n.locale = :en
    <<HTML.should == render(<<HAML)
<p>Magic translations works!</p>
<p>And this one does not exist</p>
<p>Here with interpolation, and everything thanks to I18n and GetText</p>
HTML
%p Magic translations works!
%p And this one does not exist
%p Here with interpolation, and everything thanks to \#{I18n.name} and \#{GetText.name}
HAML
  end
  
  it 'should translate text with multiline plain text' do 
    Haml::Template.options[:magic_translations] = true
    I18n.locale = :pl
    <<HTML.should == render(<<HAML)
<p>Magiczne tłumaczenie działa!</p>
<p>
  Kolejny wieloliniowy tekst,
  który powinien zostać przetłumaczony,
  interpolacja INTERPOLATION też działa!
</p>
HTML
%p Magic translations works!
%p 
  Now we will check multiline strings,
  which should be also translated,
  with interpolation \#{'Interpolation'.upcase}
HAML
  end
  
  it 'should leave text without changes when :magic_translations option is off' do 
    Haml::Template.options[:magic_translations] = false
    <<HTML.should == render(<<HAML)
<p>Text without changes</p>
HTML
%p Text without changes
HAML
  end  
end
