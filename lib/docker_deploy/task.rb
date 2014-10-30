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
              on stage.servers do
                execute :docker, "pull #{context.image}"
              end
            end

            desc "Stop the application and remove its container"
            task :stop do
              on stage.servers do
                execute :docker, "inspect #{context.container} 2>&1 > /dev/null && docker stop #{context.container} && docker rm #{context.container} || true"
              end
            end

            desc "Start the application in a container using the latest image."
            task :start do
              on stage.servers do
                execute :docker, "run -d #{stage.mappings} #{stage.options} --name #{context.container} #{context.image}:latest"

                puts "\n\nStarted: #{stage.host}\n"
              end
            end

            desc "Run migrations in the latest image."
            task :migrate do
              on stage.servers.first do
                execute :docker, "run #{stage.options} -i -t --rm=true #{context.image}:latest bundle exec rake db:create db:migrate"
              end
            end

            desc "Run a Rails console in the container"
            task :console do
              puts "Console is currently broken :("
              puts "Run:\n"
              puts "ssh #{stage.servers.first}"
              puts "docker run #{stage.options} -i -t --rm=true #{context.image}:latest bundle exec rails console"
            end

            desc "Restart the running container."
            task restart: [:stop, :start]
          end
        end
      end
    end
  end
end
