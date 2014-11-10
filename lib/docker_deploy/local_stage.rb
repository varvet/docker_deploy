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
    alias_method :run_once, :run
  end
end
