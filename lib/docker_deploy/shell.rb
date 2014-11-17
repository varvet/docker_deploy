module DockerDeploy
  def self.shell(server, command = nil)
    Net::SSH.start(server.hostname, server.user, server.netssh_options) do |ssh|
      channel = ssh.open_channel do |ch|
        ch.on_data do |c, data|
          $stdout.print data
        end

        ch.on_extended_data do |c, type, data|
          $stderr.print data
        end

        ch.request_pty

        if command
          ch.exec(command)
        else
          ch.send_channel_request "shell"
        end
      end

      read, write = UNIXSocket.pair

      Thread.new(write) do |write|
        loop do
          buf = $stdin.getch
          write.write(buf)
        end
      end

      read.extend(Net::SSH::BufferedIo)

      ssh.listen_to(read)

      ssh.loop do
        buf = read.read_available
        channel.send_data buf unless buf.empty?

        ssh.busy?
      end
    end
  end
end
