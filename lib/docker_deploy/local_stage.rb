module DockerDeploy
  class LocalStage < Stage
    def initialize(context)
      super(context, :local)
      @servers = []
      @deploy = ["docker:build", :restart]
    end

    def server(server)
      @servers << SSHKit::Host.new(server)
    end

    def run(cmd)
      sh(cmd)
    end
    alias_method :shell, :run
  end
end
