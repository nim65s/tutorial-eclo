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
    $ grep /deviceId /var/log/syslot
    ```
    => 0000000072eb5051

AirVantage
----------
