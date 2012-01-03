require 'sinatra/base'
module ClassAndJazz
  class WebApp < Sinatra::Base

    # PUBLIC of the web application
    ROOT    = Path.backfind('.[.git]')
    PUBLIC  = ROOT/:public
    HTML    = PUBLIC/"_assets/templates/html.whtml"

    ############################################################## Configuration
    # Serve public pages from public
    set :public_folder, PUBLIC

    # A few configuration options for logging and errors
    set :logging, true
    set :raise_errors, true
    set :show_exceptions, false

    # Domain specific configuration
    set :default_lang, "nl"

    ########################################################### Rewriting routes

    rewriting = YAML.load((PUBLIC/"rewriting.yml").read)

    rewriting["redirect"].each do |h|
      old, new = h.values_at("old", "new")
      get "/:lang#{old}" do
        redirect "#{new}?lang=#{params[:lang]}", 301
      end
    end

    rewriting["removal"].each do |url|
      get url do
        [410, {"Content-Type" => "text/plain"}, "This page does no longer exist, sorry"]
      end
    end

    ############################################################## Google routes

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

    get '/googleec799723efa513b7.html' do
      send_file PUBLIC/"_assets/google/googleec799723efa513b7.html"
    end

    get '/google4efc1a3f6ff86289.html' do
      send_file PUBLIC/"_assets/google/google4efc1a3f6ff86289.html"
    end

    ############################################################## Normal routes

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
        if (file = PUBLIC/url/"index.yml").exist?
          WLang::file_instantiate HTML, load_ctx(lang, file)
        else
          not_found
        end
      end

      def load_ctx(lang, url, ctx = {})
        until (url == PUBLIC.parent/"index.yml")
          if url.exist?
            ctx = YAML::load(url.read).merge(ctx)
            Array(ctx['includes']).each do |inc|
              path = url.parent/inc
              ctx = ctx.merge(YAML::load(path.read))
            end
          end
          url = url.dir.parent/"index.yml"
        end
        {
          :lang => lang, 
          :environment => settings.environment,
          :url => "/#{url}"
        }.merge(ctx)
      end

    end
    include Tools
    
    ############################################################## Auto start

    # start the server if ruby file executed directly
    run! if app_file == $0
  end
end
