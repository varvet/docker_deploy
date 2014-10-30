# DockerDeploy

Deploy docker containers via Rake. This is especially useful for dockerized
Ruby applications.

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'docker_deploy'
```

## Usage

In your Rakefile define your deployment setup like this:

``` ruby
DockerDeploy.task do
  image "elabs/projectpuzzle"

  env "RAILS_ENV", "production"

  port 80 => 3000

  stage :staging do
    server "ubuntu@staging.projectpuzzle.com"
    env "CANONICAL_HOST", "staging.projectpuzzle.com"
    host "http://staging.projectpuzzle.com"
  end

  stage :production do
    server "ubuntu@app1.projectpuzzle.com"
    server "ubuntu@app2.projectpuzzle.com"
    env "CANONICAL_HOST", "projectpuzzle.com"
    host "http://projectpuzzle.com"
  end
end
```

If you're packaging a Rails application you might want to add this in
`lib/tasks/docker.rake` instead.

DockerDeploy has now generated a ton of rake tasks for you. You can inspect
which ones are available by running:

``` sh
rake -T docker
```

To deploy your application to the server, the server must have docker installed
and running and available without `sudo`. See the docker documentation on setting
this up. Try running:

```
rake docker:staging:deploy
```

This should package your application, send it to the docker registry, pull it down
on the remote server and finally run it as a docker container.

## Adding a Dockerfile

These instructions assume you already have a Dockerfile set up. If you want to
package a Rails application, this might give you something to get you started:

``` dockerfile
FROM rails:onbuild
RUN bundle exec rake assets:precompile
```

## Known issues

* The `console` task is currently broken. We were unable to figure out how to
create an interactive session via `sshkit`.

## License

[MIT](LICENSE.txt)
