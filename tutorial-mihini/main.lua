-------------------------------------------------------------------------------
-- Copyright (c) 2012, 2013 Sierra Wireless and others.
-- All rights reserved. This program and the accompanying materials
-- are made available under the terms of the Eclipse Public License v1.0
-- which accompanies this distribution, and is available at
-- http://www.eclipse.org/legal/epl-v10.html
--
-- Contributors:
--     Benjamin Cabé, Sierra Wireless - initial API and implementation
--     Gaëtan Morice, Sierra Wireless - initial API and implementation
-------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- REQUIRES
-- ----------------------------------------------------------------------------

local sched  = require 'sched'
local modbus = require 'modbus'
-- Modbus Stub module to test the demo without modbus device.
--local modbus = require 'stub.modbus'
local utils  = require 'utils'
local tableutils = require "utils.table"
local airvantage = require 'airvantage'

-- ----------------------------------------------------------------------------
-- CONSTANTS
-- ----------------------------------------------------------------------------
local AV_ASSET_ID = "greenhouse"
local MODBUS_PORT = "/dev/ttyACM0" -- serial port on RaspPi
local MODBUS_CONF = {baudRate = 9600 }
local LOG_NAME = "GREENHOUSE_APP"

-- ----------------------------------------------------------------------------
-- ENVIRONMENT VARIABLES
-- ----------------------------------------------------------------------------
local modbus_client = modbus.new(MODBUS_PORT, MODBUS_CONF)
local modbus_client_pending_init = false
local av_asset

-- ----------------------------------------------------------------------------
-- DATA
-- ----------------------------------------------------------------------------
local modbus_data_address = {
	temperature = 1,
	luminosity  = 2,
	humidity    = 3,
	light      = 7,
	open      = 8
}
local modbus_data_process = {
	temperature = utils.processTemperature,
	luminosity  = utils.processLuminosity,
	humidity    = utils.processHumidity,
	light  = utils.numberToBoolean,
	open  = utils.numberToBoolean,
}
setmetatable(modbus_data_process, {__index = function (_, _) return utils.identity end})

local modbus_command_address = {
	switchLight = 7,
}
local modbus_command_process = {
	switchLight = utils.processSwitchLight
}



-- ----------------------------------------------------------------------------
-- PROCESSES
-- ----------------------------------------------------------------------------
--- Init Modbus
local function init_modbus()
	if modbus_client_pending_init then return end
	modbus_client_pending_init = true
	if modbus_client then modbus_client:close() end
	sched.wait(1)
	modbus_client = modbus.new(MODBUS_PORT, MODBUS_CONF)
	sched.wait(1)
	log(LOG_NAME, "INFO", "Modbus client re-init'ed")
	modbus_client_pending_init = false
end


--- Read Modbus Register and send it to Server
local function process_modbus ()
	if not modbus_client then
		init_modbus()
		if not modbus_client then
			log(LOG_NAME, "ERROR", "Unable to initialize  modbus.")
			return
		end
	end

	local values,err = modbus_client:readHoldingRegisters(1,0,9)

	if not values then
		log(LOG_NAME, "ERROR", "Unable to read from modbus. (%s)",(err or 'no details'))
		init_modbus()
		return
	end

	local sval, val    -- value from sensor, data value computed from the sensor value
	local buffer = {}

	for data, address in pairs(modbus_data_address) do
		sval = utils.convertRegister(values, address)
		val = modbus_data_process[data](sval)
		log(LOG_NAME, "INFO", "Read from modbus %s : (%s, %s).", data, tostring(val), tostring(sval))
		buffer[data] = val
	end

	-- Send data to Server
	if next(buffer) then
		buffer.timestamp=os.time()*1000
		log(LOG_NAME, 'INFO', "Sending to Server. Date=%s", tostring(buffer.timestamp))
		av_asset :pushdata ('data', buffer, 'now')
	end
end

--- Reacts to a request from AirVantage to toggle the switch
local function process_commands(asset, data, path)
	for commandid,commanddata in pairs(data) do 
		log(LOG_NAME, "INFO", "%s received from Server.", commandid)
	
		-- process command
		local proccesfunction = modbus_command_process[commandid]
		if not proccesfunction then
			log(LOG_NAME, "INFO", "%s command is not supported.", commandid)
			break
		end
	
		-- write it in modbus register
		local sval = proccesfunction(commanddata)
		modbus_client:writeMultipleRegisters (1, modbus_command_address[commandid], string.pack('h', sval))
		log(LOG_NAME, "INFO", "write to modbus %s: %d.",commandid,sval)
	end
	return 'ok'	
end


-- ----------------------------------------------------------------------------
-- MAIN
-- ----------------------------------------------------------------------------
local function main()
	log.setlevel("INFO")
	log(LOG_NAME, "INFO", "Application started")

	modbus_client = modbus.new(MODBUS_PORT, MODBUS_CONF)
	log(LOG_NAME, "INFO", "Modbus       - OK")

	-- AirVantage agent configuration
	assert(airvantage.init())
	log(LOG_NAME, "INFO", "Mihini agent - OK")

	av_asset = assert(airvantage.newasset(AV_ASSET_ID))
	av_asset.tree.commands.__default= process_commands
	assert(av_asset:start())

	log(LOG_NAME, "INFO", "Mihini asset - OK")

	log(LOG_NAME, "INFO", "Init done")

	sched.wait(2)
	while true do
		process_modbus()
		sched.wait(10)
	end
end

sched.run(main)
sched.loop()