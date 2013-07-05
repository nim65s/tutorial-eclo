These files came from `git://git.eclipse.org/gitroot/mihini/org.eclipse.mihini.samples.git`, in `greenhouse-m3da/mihini-greenhouse-m3da-demo/src/`

HOWTO
=====

TODO waiting for sbernard…

* get the Mihini application:
    ```bash
    $ git clone git://git.eclipse.org/gitroot/mihini/org.eclipse.mihini.samples.git
    ```
* write the launcher for this app (an executable called `run`):
    ```bash
    #!/bin/sh
    export LUA_PATH="/opt/mihini/lua/?.lua;/opt/mihini/lua/?/init.lua;?.lua"
    export LUA_CPATH="/opt/mihini/lua/?.so"
    /opt/mihini/bin/lua main.lua
    ```
* install this app
    ```bash
    $ telnet localhost 2000
    ```
    ```lua
    > appcon = require 'agent.appcon'
    >  = appcon.install('eclo','/home/pi/org.eclipse.mihini.samples/greenhouse-m3da/mihini-greenhouse-m3da-demo/src/', true)
    ```
* check the logs
    ```bash
    $ tail -f /var/log/syslog
    ```
