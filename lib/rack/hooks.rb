module Rack
  class Hooks

    HEADERS = {'Content-Type' => "text/plain"}

    def initialize(app = nil)
      @hooks = "hooks"
      @root  = nil
      @app   = app
      @not_found = proc{|env|
        [ 404, HEADERS, "Hook not found `#{env['PATH_INFO']}`" ]
      }
      @success = proc{|env|
        [ 200, HEADERS, "Hook `#{env['PATH_INFO']}` successfuly executed." ]
      }
      yield(self) if block_given?
    end
    attr_accessor :root
    attr_accessor :hooks
    attr_accessor :success
    attr_accessor :not_found

    def call(env)
      target = Path(hooks)/env['PATH_INFO'][1..-1]
      if target.file? and target.parent == Path(hooks)
        exec_script(target)
        success.call(env)
      elsif @app
        @app.call(env)
      else
        not_found.call(env)
      end
    rescue => ex
      [ 500, HEADERS, [ex.message] ]
    end

  private

    def exec_script(script)
      in_root_dir do
        bundler_safe do
          `#{script}`
        end
      end
    end

    def bundler_safe(&bl)
      if defined?(Bundler)
        Bundler::with_original_env(&bl)
      else
        yield
      end
    end

    def in_root_dir(&bl)
      if @root
        Path(@root).chdir(&bl)
      else
        yield
      end
    end

  end # class Hooks
end # module Rack