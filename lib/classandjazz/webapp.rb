require 'sinatra/base'
module ClassAndJazz
  class WebApp < Sinatra::Base

    # PUBLIC of the web application
    ROOT    = Path.backfind('.[config.ru]')
    PUBLIC  = ROOT/:public
    HTML    = PUBLIC/"_assets/templates/html.whtml"

    ############################################################## Configuration
    # Serve public pages from public
    set :public_folder, PUBLIC

    # A few configuration options for logging and errors
    set :logging, true
    set :raise_errors, false
    set :show_exceptions, false

    # Domain specific configuration
    set :default_lang, "nl"
    set :default_context, { }

    ########################################################### Rewriting routes

    rewriting = YAML.load((PUBLIC/"rewriting.yml").read)

    Array(rewriting["v1"]).each do |h|
      old, new, status = h.values_at("old", "new", "status")
      get "/:lang#{old}" do
        redirect "#{new}?lang=#{params[:lang]}", status || 301
      end
    end

    Array(rewriting["redirect"]).each do |h|
      from, to, status = h.values_at("from", "to", "status")
      get from do
        redirect to, status || 301
      end
    end

    Array(rewriting["removed"]).each do |url|
      get url do
        410
      end
    end

    ############################################################## Google routes

    get '/sitemap.xml' do
      content_type "application/xml"
      tpl = PUBLIC/"_assets/templates/sitemap.whtml"
      ctx = {:files => PUBLIC.glob("**/index.yml").map{|f|
        def f.to_url
          parent.to_s[(PUBLIC.to_s.length+1)..-1]
        end
        def f.to_priority
          size = (to_url || "").split('/').size
          (1.0 - 0.2*size)
        end
        f
      }.sort{|f1,f2| f1.to_url.to_s <=> f2.to_url.to_s}}
      WLang::file_instantiate(tpl, ctx)
    end

    get %r{/(google.*?.html)} do |url|
      send_file PUBLIC/"_assets/google"/url
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
      content_type "text/plain"
      msg = env['sinatra.error'].message rescue "Unknown error"
      "Sorry, an error occurred\n\t#{msg}"
    end

    ############################################################## Helpers
    module Tools

      def serve(lang, url)
        if (file = PUBLIC/url/"index.yml").exist?
          ctx = load_ctx(lang, file).merge(:url => "/#{url}")
          WLang::file_instantiate HTML, ctx
        else
          not_found
        end
      end

      def load_ctx(lang, url, ctx = settings.default_context)
        until (url == PUBLIC.parent/"index.yml")
          if url.exist?
            ctx = ctx_merge(load_yaml(url), ctx)
            Array(ctx['includes']).each do |inc|
              path = url.parent/inc
              ctx = ctx_merge(load_yaml(path), ctx)
            end
          end
          url = url.dir.parent/"index.yml"
        end
        ctx_merge({
          :lang => lang,
          :environment => settings.environment,
        },ctx)
      end

      def ctx_merge(left, right)
        unless left.class == right.class
          raise "Unexpected #{left.class} vs. #{right.class}"
        end
        case left
        when Array
          (right | left).uniq
        when Hash
          left.merge(right){|k,l,r|
            ctx_merge(l,r)
          }
        else
          right
        end
      end

      def load_yaml(path)
        YAML::load(path.read)
      rescue Exception => ex
        raise "YAML file #{path} corrupted\n\t#{ex.message}"
      end

    end
    include Tools

    ############################################################## Auto start

    # start the server if ruby file executed directly
    run! if app_file == $0
  end
end
