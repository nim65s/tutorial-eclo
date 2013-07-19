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
--     Guilhem Saurel, Sierra Wireless
-------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- REQUIRES
-- ----------------------------------------------------------------------------

local sched  = require 'sched'
local modbus = require 'modbus'
-- Modbus Stub module to test the demo without modbus device.
--local modbus = require 'stub.modbus'
local tableutils = require "utils.table"
local airvantage = require 'airvantage'

-- ----------------------------------------------------------------------------
-- CONSTANTS
-- ----------------------------------------------------------------------------
local AV_ASSET_ID = "greenhouse"
local MODBUS_PORT = "/dev/ttyACM0" -- serial port on RaspPi
local MODBUS_CONF = {baudRate = 9600}
local LOG_NAME = "GREENHOUSE_APP"

-- ----------------------------------------------------------------------------
-- PARAMETERS
-- ----------------------------------------------------------------------------
local parameters = { -- TODO: Load from persist
    consolidate = false,
}

-- ----------------------------------------------------------------------------
-- ENVIRONMENT VARIABLES
-- ----------------------------------------------------------------------------
local modbus_client = modbus.new(MODBUS_PORT, MODBUS_CONF)
local modbus_client_pending_init = false
local av_asset
local av_table
local av_table_consolidated

-- ----------------------------------------------------------------------------
-- DATA
-- ----------------------------------------------------------------------------
local modbus_data_address = {
    temperature = 0,
    luminosity  = 1,
    humidity    = 2,
    btn         = 3,
    servo       = 4,
}

local modbus_command_address = {
    servoCommand = 5,
    autoAdjust   = 6,
    adjustOffset = 7,
    adjustTemp   = 8,
    adjustLum    = 9,
    adjustHum    = 10,
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

--- Read a register
function convertRegister(value, address)
    local low = string.byte(value,2*(address + 1) - 1)
    local high = string.byte(value,2*(address + 1))
    local f = function() end
    local endianness = string.byte(string.dump(f),7)
    if(endianness == 1) then
        return high*256+low
    else
        return low*256+high
    end
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

    local values, err = modbus_client:readHoldingRegisters(1, 0, 5)

    if not values then
        log(LOG_NAME, "ERROR", "Unable to read from modbus. (%s)", (err or 'no details'))
        init_modbus()
        return
    end

    local buffer = {}

    for data, address in pairs(modbus_data_address) do
        local val = convertRegister(values, address)
        log(LOG_NAME, "INFO", "Read from modbus %s : %f.", data, val)
        buffer[data] = val
    end

    if buffer['btn'] == 1 then
        buffer['btn'] = true
        if parameters['consolidate'] then
            buffer.timestamp=os.time()
            log(LOG_NAME, 'INFO', "Button pushed ; Sending to Server. Date=%s", tostring(buffer.timestamp))
            av_asset :pushdata ('data', buffer, 'now')
        end
        modbus_client:writeMultipleRegisters (1, modbus_data_address['btn'], string.pack('h', 0))
    else
        buffer['btn'] = false
    end

    -- Send data to Server
    if next(buffer) then
        buffer.timestamp=os.time()
        if parameters['consolidate'] then
            log(LOG_NAME, 'INFO', "Adding Row. Date=%s", tostring(buffer.timestamp))
            av_table :pushRow(buffer)
        else
            log(LOG_NAME, 'INFO', "Sending to Server. Date=%s", tostring(buffer.timestamp))
            av_asset :pushdata ('data', buffer, 'now')
        end
    end
end

--- Reacts to a request from AirVantage
local function process_commands(asset, data, path)
    for _, datas in pairs(data) do
        for _, command in pairs(datas) do
            for parameter, value in pairs(command) do
                if parameters[parameter] then
                    parameters[parameter] = value
                elseif modbus_command_address[parameter] then
                    if value == true then
                        value = 1
                    elseif value == false then
                        value = 0
                    end
                    modbus_client:writeMultipleRegisters (1, modbus_command_address[parameter], string.pack('h', value))
                else
                    log(LOG_NAME, "INFO", "parameter '%s' unknown (value '%s')", parameter, value)
                end
            end
        end
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
    av_asset.tree.commands.__default = process_commands
    assert(av_asset:start())

    log(LOG_NAME, "INFO", "Mihini asset - OK")

    av_table = av_asset :newTable('rawdata', {'timestamp', 'temperature', 'luminosity', 'humidity', 'servo'}, 'file', 'never')
    local conso_err
    av_table_consolidated, conso_err = av_table :newConsolidation('data',
        { timestamp='median', temperature='mean', luminosity='mean', humidity='mean', servo='last'},
        'file', 'everyminute', 'every15minutes')

    if av_table_consolidated then
        log(LOG_NAME, "INFO", "Mihini table - OK")
    else
        log(LOG_NAME, "ERROR", "Mihini table consolidated: %s", conso_err)
    end

    log(LOG_NAME, "INFO", "Init done")

    sched.wait(2)
    while true do
        process_modbus()
        sched.wait(29)
    end
end

sched.run(main)
sched.loop()
