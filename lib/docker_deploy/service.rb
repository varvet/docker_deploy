module DockerDeploy
  class Service
    attr_reader :name, :command

    def initialize(stage, name)
      @stage = stage
      @name = name
      @ports = {}
    end

    def command(name = nil)
      @command = name if name
      @command
    end

    def port(ports = {})
      @ports.merge!(ports)
    end

    def port_mappings
      DockerDeploy.format_params("-p %s:%s", @ports)
    end

    def container(name = nil)
      @container = name if name
      @container or "#{@stage.container}_#{@name}"
    end
  end
end
