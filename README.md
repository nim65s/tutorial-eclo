tutorial-eclo
=============

Tutorial for the eclo greenhouse

NB: this is currently a work in progress.
A few links may work but are not intended to be definitive.


Arduino
-------

This program is based on [kartben/mihini-greenhouse-demo](https://github.com/kartben/mihini-greenhouse-demo).

* Download the [arduino IDE](http://arduino.cc/en/Main/Software) and launch it
* Open the file `tutorial_arduino/tutorial_arduino.ino`
* Download the [SimpleModbusSlave V4](https://code.google.com/p/simple-modbus/downloads/detail?name=SimpleModbusSlaveV4.zip&can=2&q=) library, and [install](http://arduino.cc/en/Guide/Libraries) it.
* Connect your Arduino in USB and flash it

Raspberry Pi
------------

* Follow the [Raspberry Pi's quick start guide](http://www.raspberrypi.org/quick-start-guide) and choose a Raspbian in the NOOBS screen
* Once you are logged onto your Raspbian, download and install [Mihini](http://wiki.eclipse.org/Mihini/Install_Mihini#Download) (choose the "armhf" architecture, and the "deb" package type)
* check the airvantage server url, in `/opt/mihini/lua/agent/defaultconfig.lua`, line 27
* find the deviceId:

```bash
$ grep deviceId /var/log/syslog
```

=> you should find something like `0000000072eb5051`

Mihini's application
--------------------

This program is based on [the Mihini samples from Eclipse’s git repository](http://git.eclipse.org/c/mihini/org.eclipse.mihini.samples.git/), in `greenhouse-m3da/mihini-greenhouse-m3da-demo/src/`

### Using Lua Development Tools

* On your Desktop computer, download and launch [LDT](http://www.eclipse.org/koneki/ldt/#installation)
* Install the Mihini Development Tools
    * Help -> Install new software
    * Work with: `http://download.eclipse.org/koneki/updates-nightly`
    * Select the "Mihini Development Tools for Lua"
    * Restart Eclipse if it's recommended
* Configure the connection to your Raspberry Pi
    * Open the perspective "Remote System explorer"
    * "Define a connection to remote system" -> "Mihini Device"
    * Fill the "Host name" with your Raspberry Pi's IP address, and "Finish"
    * Right clic on "Applications", then "Connect…", and fill your credential (user: `pi` & password: `raspberry`)
* Create the Eclipse's Project
    * Get back to the Lua Perspective
    * File -> New -> LUA Project
    * Name it, with only ASCII letters, digits and "_"
    * "Create project at existing location (from existing source)" -> select the `tutorial_mihini` folder
* Install your Project on you Raspberry Pi
    * Right-click on your application -> Export -> Mihini -> Lua Application Package
    * give it a Version

* Checks the log on your Raspbian

```bash
$ tail -f /var/log/syslog
```

For more details, see the [official LDT's User guide](http://wiki.eclipse.org/Koneki/LDT/Developer_Area/User_Guides/User_Guide_1.0#Remote_session)

### OR Using the telnet lua console

* On your Raspberry Pi, download the application:

```bash
$ cd
$ sudo apt-get install git
$ git clone https://github.com/nim65s/tutorial_eclo.git
```

* Install the application

```bash
$ telnet localhost 2000
```

```lua
> appcon = require "agent.appcon"
> = appcon.install("eclo", "/home/pi/tutorial-eclo/tutorial_mihini", true)
```

We can check that the application is properly installed

```lua
> for app, t in pairs(appcon.list()) do
     print( app )
     for field, data in pairs(t) do
         print("\t", field, data)
     end
end
```

```lua
eclo
                autostart       true
                runnable        true
```

**Notice**: `CTRL-D` to quit.

* check the logs

```bash
$ tail -f /var/log/syslog
```

**Notice**: `CTRL-C` to quit.

AirVantage
----------
* Add the tarball of `tutorial_mihini` to `tutorial_airvantage`:

```bash
$ tar cvf tutorial_mihini.tar tutorial_mihini
$ mv tutorial_mihini.tar tutorial_airvantage
```

* Zip the `tutorial_airvantage/model.app`

```bash
$ cd tutorial_airvantage
$ zip model.app.zip model.app
```

* Create an AirVantage Trial account on the [Sierra Wireless' Developer Zone](http://developer.sierrawireless.com/Cloud%20Platform.aspx)
* Once you are logged in AirVantage, create a new application and publish it
    * Develop -> My Apps
    * Release -> Select a File -> `model.app.zip` -> Start
    * Refresh -> Select "My Application" -> Publish -> Publish
* Then you can add a your Raspberry Pi as a system in your AirVantage's fleet
    * Inventory -> Systems -> Create
    * Give it a name
    * Create a gateway with the deviceId as the Serial Number
    * Don't add any subscription
    * Add the Application you just created
    * Let the Password field empty
    * Create
* Select your new system and activate it
* Check that Mihini is successfully connected to AirVantage
    * Monitor -> Systems
    * Select your system -> Details
    * History
