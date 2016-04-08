require "sshkit"
require "sshkit/dsl"
require "shellwords"
require "io/console"

require "docker_deploy/version"
require "docker_deploy/shell"
require "docker_deploy/service"
require "docker_deploy/context"
require "docker_deploy/stage"
require "docker_deploy/remote_stage"
require "docker_deploy/local_stage"
require "docker_deploy/task"

module DockerDeploy
  def self.format_params(pattern, enumerable)
    enumerable.map do |args|
      args = [args].flatten.map { |v| Shellwords.escape(v) }
      pattern % args
    end.join(" ")
  end
end

# Improvement on the broken piece of crap text formatter in SSHKit.
class PlainFormatter < SSHKit::Formatter::Abstract
  def initialize(io = $stdout)
    @io = io
  end

  def write(obj)
    if obj.is_a?(SSHKit::Command)
      @io.write(obj.full_stdout)
    else
      @io.write(obj.to_s)
    end
  end

  alias_method :<<, :write
end

SSHKit.configure do |config|
  config.output = PlainFormatter.new($stdout)
  config.command_map["docker"] = "/usr/bin/env docker"
  # config.output_verbosity = Logger::DEBUG
end

SSHKit::Backend::Netssh.config.pty = true
