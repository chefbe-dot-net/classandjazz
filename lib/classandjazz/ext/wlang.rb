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
    text = Kramdown::Document.new(text).to_html
    [text, reached]
  end

  rule '@' do |parser, offset|
    link, offset = parser.parse(offset)
    if parser.has_block?(offset)
      sublink, offset = parser.parse_block(offset)
      link += "/" unless link[-1,1] == '/'
      link += sublink
    end
    link = "#{link}?lang=#{parser.evaluate('lang')}"
    [link, offset]
  end

end
