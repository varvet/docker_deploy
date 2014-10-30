module DockerDeploy
  class Context
    attr_reader :stages, :environment, :ports

    def initialize
      @stages = []
      @environment = {}
      @ports = []
    end

    def env(key, value)
      @environment[key] = value
    end

    def port(ports = {})
      @ports.merge!(ports)
    end

    def image(name = nil)
      @image = name if name
      @image
    end

    def container
      @image.split("/").last
    end

    def stage(name, &block)
      stage = Stage.new(self, name)
      stage.instance_eval(&block)
      @stages << stage
    end
  end
end
