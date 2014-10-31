module DockerDeploy
  class Stage
    attr_reader :name, :servers, :variables, :links

    def initialize(context, name)
      @context = context
      @name = name
      @servers = []
      @variables = {}
      @ports = {}
      @links = {}
      @deploy = ["docker:build", "docker:push", :pull, :restart]
    end

    def env(variables = {})
      @variables.merge!(variables)
    end

    def port(ports = {})
      @ports.merge!(ports)
    end

    def link(links = {})
      @links.merge!(links)
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

    def link_mappings
      @context.links.merge(@links).each_with_object("") do |(from, to), s|
        s << " --link %s:%s " % [from, to]
      end
    end

    def port_mappings
      @context.ports.merge(@ports).each_with_object("") do |(from, to), s|
        s << " -p %d:%d " % [from, to]
      end
    end

    def options
      @context.variables.merge(@variables).each_with_object("") do |(k, v), s|
        s << " -e %s=%s " % [Shellwords.escape(k), Shellwords.escape(v)] if v.present?
      end
    end
  end
end
