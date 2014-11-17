module DockerDeploy
  class Stage
    include Rake::FileUtilsExt

    attr_reader :name, :servers, :variables, :links, :env_files, :deploy, :container, :services

    def initialize(context, name)
      @context = context
      @name = name
      @env_files = []
      @services = []
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

    def env_file(env_file)
      @env_files.push(env_file)
    end

    def host(name = nil)
      @host = name if name
      @host
    end

    def link_mappings
      DockerDeploy.format_params("--link %s:%s", @context.links.merge(@links))
    end

    def port_mappings
      DockerDeploy.format_params("-p %s:%s", @context.ports.merge(@ports))
    end

    def options
      DockerDeploy.format_params("--env-file %s", @context.env_files + @env_files) + " " +
      DockerDeploy.format_params("-e %s=%s", @context.variables.merge(@variables))
    end

    def container(name = nil)
      @container = name if name
      @container or @context.container
    end

    def service(name, &block)
      service = Service.new(self, name)
      service.instance_eval(&block)
      @deploy << "#{name}:restart"
      @services << service
    end
  end
end
