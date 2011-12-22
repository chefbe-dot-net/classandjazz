require 'sinatra/base'
module ClassAndJazz
  class WebApp < Sinatra::Base

    # PUBLIC of the web application
    ROOT    = Path.backfind('.[.git]')
    PUBLIC  = ROOT/:public

    ############################################################## Configuration
    # Serve public pages from public
    set :public_folder, PUBLIC

    # A few configuration options for logging and errors
    set :logging, true
    set :raise_errors, true
    set :show_exceptions, false

    # Domain specific configuration
    set :default_lang, "nl"

    ############################################################## Routes

    get '/sitemap.xml' do
      content_type "application/xml"
      tpl = PUBLIC/"sitemap.whtml"
      ctx = {:files => PUBLIC.glob("**/index.yml").map{|f|
        def f.to_url
          parent.to_s[(PUBLIC.to_s.length+1)..-1]
        end
        f
      }}
      WLang::file_instantiate(tpl, ctx)
    end

    get '/' do
      lang = params["lang"] || settings.default_lang
      serve(lang, "")
    end

    get %r{^/(.+)} do
      lang = params["lang"] || settings.default_lang
      page = params[:captures].first
      serve(lang, page)
    end

    ############################################################## Error handling

    # error handling
    error do
      'Sorry, an error occurred'
    end

    ############################################################## Helpers
    module Tools

      def serve(lang, url)
        file = PUBLIC/url/"index.yml"
        if file.exist?
          ctx = load_ctx(lang, file).merge(:url => "/#{url}")
          tpl = PUBLIC/"_assets/templates/html.whtml"
          WLang::file_instantiate(tpl, ctx)
        else
          not_found
        end
      end

      def load_ctx(lang, url)
        ctx = {}
        while url.exist?
          ctx = YAML::load(url.read).merge(ctx)
          url = url.dir.parent/"index.yml"
        end
        {
          :lang => lang, 
          :environment => settings.environment
        }.merge(ctx)
      end

    end
    include Tools
    
    ############################################################## Auto start

    # start the server if ruby file executed directly
    run! if app_file == $0
  end
end
