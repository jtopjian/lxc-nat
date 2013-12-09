## lxc-nat.rb

Simple ruby script to create port-forwarding rules based on a static table.

## Configuration

Create `/etc/lxc/lxc-nat.conf` with rules such as the following:

```
src_ip:port -> lxc_container:port
10.0.0.1:80 -> www:80
10.0.0.1:3306 -> mysql_server:3306
```

## TODO

* better cli arg handling
* daemon/event mode
