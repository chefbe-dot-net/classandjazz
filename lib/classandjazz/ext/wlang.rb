require 'wlang'
require 'wlang/dialects/xhtml_dialect'

WLang::dialect('whtml', '.whtml') do
  encoders WLang::EncoderSet::XHtml
  rules    WLang::RuleSet::Basic
  rules    WLang::RuleSet::Imperative
  rules    WLang::RuleSet::Encoding
  rules    WLang::RuleSet::Buffering

  rule '+' do |parser,offset|
    text, reached = parser.parse(offset)
    text = parser.evaluate(text)
    [text, reached]
  end

  rule '@' do |parser, offset|
    href, offset = parser.parse(offset)
    href = "#{href}?lang=#{parser.evaluate('lang')}" unless href =~ /^[a-z]+:/
    if parser.has_block?(offset)
      label, offset = parser.parse_block(offset)
      [ClassAndJazz.makelink(href, label), offset]
    else 
      [href, offset]
    end
  end

  rule '~' do |parser, offset|
    text, offset = parser.parse(offset)
    text = parser.evaluate(text)
    text, _ = parser.branch(
      :template => WLang::template(text, "active-markdown"),
      :offset   => 0,
      :shared   => :all) do
      parser.instantiate
    end 
    [text, offset]
  end

end

WLang::dialect("active-markdown") do

  rule '@' do |parser, offset|
    href, offset = parser.parse(offset)
    href = "#{href}?lang=#{parser.evaluate('lang')}" unless href =~ /^[a-z]+:/
    if parser.has_block?(offset)
      label, offset = parser.parse_block(offset)
      [ClassAndJazz.makelink(href, label), offset]
    else 
      [href, offset]
    end
  end

  post_transform do |text|
    Kramdown::Document.new(text).to_html
  end

end
