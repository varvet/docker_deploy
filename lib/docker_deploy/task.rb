module DockerDeploy
  def self.task(ns = :docker, &block)
    main = TOPLEVEL_BINDING.eval("self")

    context = Context.new
    context.instance_eval(&block)

    main.instance_eval do
      namespace ns do

        desc "Builds the application"
        task :build do
          sh "docker build -t #{context.image} ."
        end

        desc "Push the application to docker"
        task :push do
          sh "docker push #{context.image}"
        end

        context.stages.each do |stage|
          namespace stage.name do

            desc "deploy the application"
            task deploy: stage.deploy

            desc "pull down code from repository"
            task :pull do
              on stage.servers do
                execute :docker, "pull #{context.image}"
              end
            end

            desc "Stop any running containers."
            task :stop do
              on stage.servers do
                execute :docker, "inspect #{context.container} 2>&1 > /dev/null && docker stop #{context.container} && docker rm #{context.container} || true"
              end
            end

            desc "Start a #{context.container} container using the latest image."
            task :start do
              on stage.servers do
                execute :docker, "run -d #{stage.mappings} #{stage.options} --name #{context.container} #{context.image}"

                puts "\n\nStarted: #{stage.host}\n"
              end
            end

            desc "Run migrations in the latest known Docker image."
            task :migrate do
              on stage.servers.first do
                execute :docker, "run #{stage.options} -i -t --rm=true #{context.image} bundle exec rake db:create db:migrate"
              end
            end

            desc "Run a Rails console in the container"
            task :console do
              puts "Console is currently broken :("
              puts "Run:\n"
              puts "ssh #{stage.servers.first}"
              puts "docker run #{stage.options} -i -t --rm=true #{context.image} bundle exec rails console"
            end

            desc "Restart the running containers. This will reboot them with the new code."
            task restart: [:stop, :start]
          end
        end
      end
    end
  end
end
