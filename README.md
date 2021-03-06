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

### Consolidation & Send Policies ###

In the M2M world, communications are expensive, so we try to send consolidated data, and to send those consolidated datas with a period which fits our wallet.

That's why in this sample, the Arduino get the sensors value at a high frequency (every 50ms), but Mihini get those values slower (every 10s), then consolidate (average, most of the time) them every minute, and then send them to the server every 15 minutes.

But of course, you don't want to wait 15 minutes to see your data on the cloud, so we gave you a button to send the data in the 10s needed by Mihini to get them.

AirVantage
----------
* Add the tarball of `tutorial_mihini` to `tutorial_airvantage`:

```bash
$ tar cvf tutorial_mihini.tar tutorial_mihini
$ mv tutorial_mihini.tar tutorial_airvantage
```

* Zip the application

```bash
$ cd tutorial_airvantage
$ zip model.app.zip model.app tutorial_mihini.tar
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

REST API
--------

This is a sample in Python of the usage of the API documented in AirVantage -> Develop -> API documentation.
It is based on the [Request Library](http://docs.python-requests.org/en/latest/), which can be installed with `pip install requests`.

* Firstly, you will need an API key:
    * In AirVantage, Develop -> API clients -> Create -> give it a name
* Then you will have to get an `access_token`. There are three methods, I will use the easiest:

```python
#!/usr/bin/python
import json
import requests

SERVER_URL = 'http://edge.m2mop.net/'
USERNAME = 'eclo.demo@gmail.com'
PASSWORD = 'eclo-live2013!'
CLIENT_ID = 'eabea6f63e8346ceb8c4016f8e0f2740'
CLIENT_SECRET = '54f40d77bbe348cb9e8b274fa25625ba'

access_url = 'api/oauth/token?grant_type=password&username=%s&password=%s&client_id=%s&client_secret=%s' % (USERNAME, PASSWORD, CLIENT_ID, CLIENT_SECRET)
access_token = requests.get(SERVER_URL + access_url).json()['access_token']
token_params = { 'access_token': access_token }
```
* Once your credentials are corrects, you will need your system's uid

```python
system_url = 'api/v1/systems'
sys_uid = requests.get(SERVER_URL + system_url, params=token_params).json()['items'][0]['uid']
```

* Now, with this uid, you can get your data:

```python
data_url = 'api/v1/systems/%s/data' % sys_uid
```

* Or even the history of these data:

```python
luminosity_history_url = 'api/v1/systems/%s/data/greenhouse.data.luminosity/raw' % sys_uid
```

NB: you can get the date from the `timestamp` with

```python
from datetime import datetime
dt = datetime.fromtimestamp(timestamp/1000)
```

* Now if you want to send a command to your system, you need your application's uid:

```python
params = token_params.copy()
params['type'] = 'tutorial_eclo'
app_uid = requests.get(SERVER_URL + 'api/v1/applications', params=params).json()['items'][0]['uid']
```

* Then create a json-serialized dict with the data you want to POST (in this example, we want to set manually the Servo's at 50°):

```python
data = json.dumps({
    "application" : { "uid": app_uid },
    "systems" : { "uids": [sys_uid] },
    "commandId": "greenhouse.data.roof",
    "parameters": {
        "autoAdjust": False,
        "servoCommand": 50,
        }
})
```

* And post it:

```python
json_headers = {'content-type': 'application/json'}
r = requests.post(SERVER_URL + 'api/v1/operations/systems/command', data=data, params=token_params, headers=json_headers)
```

* In the response, you can get the operation Id, which is usefull to know its status:

```python
operation_params = token_params.copy()
operation_params['uid'] = r.json()['operation']
response = requests.get(SERVER_URL + 'api/v1/operations', params=operation_params)
print response.json()
```

* In this application, you can also change the parameters which govern the auto-adjust equation of the roof:

```python
if autoAdjust:
    roof  = adjustOffset
    roof += adjustTemp * temperature
    roof += adjustLum  * luminosity
    roof += adjustHum  * Humidity
else:
    roof = servoCommand
```

