module DockerDeploy
  def self.task(ns = :docker, &block)
    main = TOPLEVEL_BINDING.eval("self")

    context = Context.new
    context.instance_eval(&block)

    main.instance_eval do
      namespace ns do

        desc "Builds the application into a docker image"
        task :build do
          sh "docker build -t #{context.image}:#{context.revision} -t #{context.image}:latest ."
        end

        desc "Push the application's docker image to the docker registry"
        task :push do
          sh "docker push #{context.image}"
        end

        context.stages.each do |stage|
          namespace stage.name do

            desc "deploy the application"
            task deploy: stage.deploy

            desc "Stop the application and remove its container"
            task :stop do
              stage.run "docker inspect #{stage.container} 2>&1 > /dev/null && docker kill #{stage.container} && docker rm #{stage.container} || true"
            end

            desc "Start the application in a container using the latest image."
            task :start do
              stage.run "docker run -d #{stage.port_mappings} #{stage.link_mappings} #{stage.options} --name #{stage.container} #{context.image}:latest"

              puts "\n\nstarted: #{stage.host}\n"
            end

            desc "Restart the running container."
            task restart: [:stop, :start]

            stage.services.each do |service|
              namespace service.name do
                desc "Stop the #{service.name} service and remove its container"
                task :stop do
                  stage.run "docker inspect #{service.container} 2>&1 > /dev/null && docker kill #{service.container} && docker rm #{service.container} || true"
                end

                desc "Start the #{service.name} service in a container using the latest image."
                task :start do
                  stage.run "docker run -d #{service.port_mappings} #{stage.link_mappings} #{stage.options} --name #{service.container} #{context.image}:latest #{service.command}"
                end

                desc "Restart the #{service.name} service."
                task restart: [:stop, :start]

                desc "Tail log of the #{service.name} service."
                task :tail do
                  stage.run "docker logs --tail 50 -f #{service.container}"
                end
              end

              task start: "#{service.name}:start"
              task stop: "#{service.name}:stop"
            end

            desc "Run migrations in the latest image."
            task :migrate do
              stage.shell "docker run #{stage.link_mappings} #{stage.options} -i -t --rm=true #{context.image}:latest bundle exec rake db:create db:migrate"
            end

            desc "Run a Rails console in a container"
            task :console do
              stage.shell "docker run #{stage.options} -i -t --rm=true #{stage.link_mappings} #{context.image}:latest bundle exec rails console"
            end

            desc "Run a shell in a container"
            task :shell do
              stage.shell "docker run #{stage.options} -i -t --rm=true #{stage.link_mappings} #{context.image}:latest /bin/bash"
            end

            desc "Tail log files"
            task :tail do
              stage.run "docker logs --tail 50 -f #{stage.container}"
            end

            if stage.is_a?(RemoteStage)
              desc "Pull down code from the docker registry"
              task :pull do
                stage.run "docker pull #{context.image}"
              end

              desc "SSH into a host server"
              task :ssh do
                stage.shell
              end
            end
          end
        end
      end
    end
  end
end
