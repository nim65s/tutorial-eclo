modbus = require 'modbus'
local MODBUS_PORT = "/dev/ttyACM0"
local MODBUS_CONF = {baudRate = 9600}
local modbus_client = modbus.new(MODBUS_PORT, MODBUS_CONF)
if not modbus_client then
    print('ko')
else
    print('ok')
end
