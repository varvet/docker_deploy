module DockerDeploy
  class Stage
    attr_reader :name, :servers, :environment

    def initialize(context, name)
      @context = context
      @name = name
      @servers = []
      @environment = {}
      @deploy = ["docker:build", "docker:push", :pull, :restart]
    end

    def env(key, value)
      @environment[key] = value
    end

    def deploy(sequence = nil)
      @deploy = sequence if sequence
      @deploy
    end

    def host(name = nil)
      @host = name if name
      @host
    end

    def server(server)
      @servers << SSHKit::Host.new(server)
    end

    def options
      @context.environment.merge(@environment).each_with_object("") do |(k, v), s|
        s << " -e %s=%s " % [Shellwords.escape(k), Shellwords.escape(v)] if v.present?
      end
    end
  end
end
