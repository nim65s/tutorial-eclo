tutorial-eclo
=============

Tutorial for the eclo greenhouse

hardware
--------

Arduino
-------

This program cames from [kartben/mihini-greenhouse-demo](https://github.com/kartben/mihini-greenhouse-demo).

* Download the [arduino IDE](http://arduino.cc/en/Main/Software) and launch it
* Open the file `tutorial-arduino/SimpleModbusSlaveExample.ino`
* Download the [SimpleModbusSlave](https://code.google.com/p/simple-modbus/downloads/detail?name=SimpleModbusSlaveV4.zip&can=2&q=) library, and [install](http://arduino.cc/en/Guide/Libraries) it.
* Connect your Arduino in USB and flash it

Raspberry Pi
------------

* Follow the [Raspberry Pi's quick start guide](http://www.raspberrypi.org/quick-start-guide)
* Once you are logged onto your Raspbian, install [mihini](http://wiki.eclipse.org/Mihini/Install_Mihini#Others)
* Follow the `tutorial-mihini/README.md`
* check the airvantage server url, in `/opt/mihini/lua/agent/defaultconfig.lua`, line 27
* find the deviceId:

    ```bash
    $ grep deviceId /var/log/syslot
    ```
    => you should find something like `0000000072eb5051`

AirVantage
----------

* Zip the `tutorial-airvantage/model.app`
    ```bash
    $ cd tutorial-airvantage
    $ zip model.app.zip model.app
    ```
* Create an AirVantage account
* Once you are logged in AirVantage, create a new application and publish it
    * Develop -> My Apps
    * Release -> Select a File -> model.app.zip -> Start
    * Refresh -> Select «My Application» -> Publish -> Publish
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
