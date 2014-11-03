module DockerDeploy
  class Context
    attr_reader :stages, :variables, :ports, :links, :env_files

    def initialize
      @stages = []
      @env_files = []
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

    def env_file(env_file)
      @env_files.push(env_file)
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
