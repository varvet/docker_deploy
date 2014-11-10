module DockerDeploy
  class RemoteStage < Stage
    def initialize(context, name)
      super
      @servers = []
    end

    def server(server)
      @servers << SSHKit::Host.new(server)
    end

    def run(cmd)
      on servers do
        execute(cmd)
      end
    end

    def run_once(cmd)
      on servers.first do
        execute(cmd)
      end
    end
  end
end
