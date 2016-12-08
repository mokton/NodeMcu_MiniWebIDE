-- Begin WiFi configuration
local wifiConfig = {}
-- wifi.STATION    -- station: join a WiFi network-- wifi.SOFTAP     -- access point: create a WiFi network
-- wifi.STATIONAP  -- both station and access point
wifiConfig.mode = wifi.STATION  -- both station and access point
print("Setting wifi mode to station...")
wifiConfig.ap_conf = {}
wifiConfig.ap_conf.ssid = "ESP-"..node.chipid()   -- Name of the SSID you want to create
wifiConfig.ap_conf.pwd = "ESP-"..node.chipid()    -- WiFi password - at least 8 characters
wifiConfig.ap_ip_conf = {}
wifiConfig.ap_ip_conf.ip = "10.0.0.1"
wifiConfig.ap_ip_conf.netmask = "255.255.255.0"
wifiConfig.ap_ip_conf.gateway = "10.0.0.1"

wifiConfig.sta_conf = {}
wifiConfig.sta_conf.ssid = "wifi_SSID"    -- Name of the WiFi network you want to join
wifiConfig.sta_conf.pwd =  "wifi_Password"   -- Password for the WiFi network
-- Tell the chip to connect to the access point
wifi.setmode(wifiConfig.mode)
print('Set (Wifi mode='..wifi.getmode()..')')
function wifi_connect()
    if (wifiConfig.mode == wifi.SOFTAP) or (wifiConfig.mode == wifi.STATIONAP) then
        print('AP MAC: '..wifi.ap.getmac())
        wifi.ap.config(wifiConfig.ap_conf)
        wifi.ap.setip(wifiConfig.ap_ip_conf)
    end
    if (wifiConfig.mode == wifi.STATION) or (wifiConfig.mode == wifi.STATIONAP) then
        print('Client MAC: '..wifi.sta.getmac())
        wifi.sta.config(wifiConfig.sta_conf.ssid, wifiConfig.sta_conf.pwd, 1)
        wifi.sta.connect()
    end
end
print("Connecting to WiFi access point...")
wifi_connect()
print('Chip ID: ',node.chipid())
print('Heap: ',node.heap())
function startup()
    if file.open("webide.lua") == nil then
        print("webide.lua deleted or renamed")
    else
        print("Running")
        file.close("webide.lua")
        srv = dofile("webide.lua")(80)
    end
end
tmr.alarm(1, 1000, 1, function()
    if wifi.sta.getip() == nil then
        print("Waiting for IP address...")
    else
        tmr.stop(1)
        print("WiFi connection established, IP address: " .. wifi.sta.getip())
        print("You have 5 seconds to abort")
        print("Waiting...")
        tmr.alarm(1, 5000, 0, startup)
    end
end)