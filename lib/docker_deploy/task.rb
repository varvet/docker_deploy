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

            desc "Pull down code from the docker registry"
            task :pull do
              stage.run "docker pull #{context.image}"
            end

            desc "Stop the application and remove its container"
            task :stop do
              stage.run "docker inspect #{context.container} 2>&1 > /dev/null && docker stop #{context.container} && docker rm #{context.container} || true"
            end

            desc "Start the application in a container using the latest image."
            task :start do
              stage.run "docker run -d #{stage.port_mappings} #{stage.link_mappings} #{stage.options} --name #{context.container} #{context.image}:latest"

              puts "\n\nStarted: #{stage.host}\n"
            end

            desc "Run migrations in the latest image."
            task :migrate do
              stage.run_once "docker run #{stage.link_mappings} #{stage.options} -i -t --rm=true #{context.image}:latest bundle exec rake db:create db:migrate"
            end

            desc "Run a Rails console in a container"
            task :console do
              cmd = "docker run #{stage.options} -i -t --rm=true #{stage.link_mappings} #{context.image}:latest bundle exec rails console"
              if stage.is_a?(RemoteStage)
                puts "Console is currently broken :("
                puts "SSH in and run:\n"
                puts cmd
              else
                stage.run_once(cmd)
              end
            end

            desc "Run a shell in a container"
            task :shell do
              cmd = "docker run #{stage.options} -i -t --rm=true #{stage.link_mappings} #{context.image}:latest /bin/bash"
              if stage.is_a?(RemoteStage)
                puts "Shell is currently broken :("
                puts "SSH in and run:\n"
                puts cmd
              else
                stage.run_once(cmd)
              end
            end

            desc "Restart the running container."
            task restart: [:stop, :start]
          end
        end
      end
    end
  end
end
