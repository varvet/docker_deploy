module DockerDeploy
  class Context
    attr_reader :stages, :variables, :ports, :links

    def initialize
      @stages = []
      @variables = {}
      @ports = {}
      @links = {}
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

    def image(name = nil)
      @image = name if name
      @image
    end

    def container
      @image.split("/").last
    end

    def revision
      @revision ||= `git rev-parse HEAD`.chomp[0...8]
    end

    def stage(name, &block)
      stage = Stage.new(self, name)
      stage.instance_eval(&block)
      @stages << stage
    end
  end
end
