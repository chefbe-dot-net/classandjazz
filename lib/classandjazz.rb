require 'yaml'
require 'logger'
require 'classandjazz/loader'
require 'classandjazz/ext/hash'
require 'classandjazz/ext/nocache'
require 'classandjazz/ext/wlang'
require 'classandjazz/webapp'
module ClassAndJazz

  def internal?(url)
    url && !(url =~ /^(https?|ftp|mailto):/) && !(url =~ /ajax.googleapis.com/)
  end
  module_function :internal?
  
  def external?(url)
    !internal?(url)
  end
  module_function :external?

  def makelink(url, label = url)
    label = url unless label
    if external?(url)
      %Q{<a target="_blank" href="#{url}">#{label}</a>}
    else
      %Q{<a href="#{url}">#{label}</a>}
    end
  end
  module_function :makelink

end # module ClassAndJazz