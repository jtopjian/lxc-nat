#!/usr/bin/env ruby
#
## lxc-nat.rb
#
# Simple ruby script to create port-forwarding rules based on a static table.
#
## Configuration
#
# Create /etc/lxc/lxc-nat.conf with rules such as the following:
#
#   src_ip:port -> lxc_container:port
#   10.0.0.1:80 -> www:80
#   10.0.0.1:3306 -> mysql_server:3306
#
## TODO
#
# * better cli arg handling
# * daemon/event mode

noop  = false
flush = false
ARGV.each do |arg|
  if arg == '-f'
    flush = true
  end
  if arg == '-n'
    noop = true
  end
end

forwards = []
containers = {}

lxc_output = `lxc-ls --fancy | grep RUN`.split("\n")
lxc_output.each do |line|
  cols = line.split(/\s+/)
  containers[cols[0]] = cols[2]
end

File.open('/etc/lxc/lxc-nat.conf').each do |line|
  line.chomp!
  if line =~ /([0-9\.]+):(\d+)\s+->\s+(.*):(\d+)/
    src_ip   = $1
    src_port = $2
    lxc_name = $3
    lxc_port = $4

    if containers.include?(lxc_name)
      if noop
        puts "#{src_ip}:#{src_port} -> #{containers[lxc_name]}:#{lxc_port}"
      else
        forwards << "iptables -t nat -A lxc-nat -d #{src_ip} -p tcp --dport #{src_port} -j DNAT --to #{containers[lxc_name]}:#{lxc_port}"
      end
    end

  end

end

system('iptables -t nat -F lxc-nat')
system('iptables -t nat -D PREROUTING -j lxc-nat')
system('iptables -t nat -X lxc-nat')

unless flush or noop
  system('iptables -t nat -N lxc-nat')
  system('iptables -t nat -A PREROUTING -j lxc-nat')
  forwards.each do |f|
    system(f)
  end
end
