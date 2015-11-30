-- WiFi access parameters
SSID    = "YourSSID"
APPWD   = "YourPassword"
WIFI_SIGNAL_MODE = wifi.PHYMODE_N
wifiTrys     = 0      -- Counter of trys to connect to wifi
NUMWIFITRYS  = 200    -- Maximum number of WIFI Testings while waiting for connection

-- Your Webserver running PiThermostat
HTTPHOST = "192.168.1.130"
HTTPPORT = 80
-- Length of time to sleep for in microseconds
DEEP_SLEEP = 60000000

-- TMP102 connections
id=0
sda=5 -- ESP8266 GPIO14
scl=6 -- ESP8266 GPIO12

-- End of editable parameters

function checkWIFI() 
  if ( wifiTrys > NUMWIFITRYS ) then
    print("Sorry. Not able to connect")
  else
    ipAddr = wifi.sta.getip()
    if ( ( ipAddr ~= nil ) and  ( ipAddr ~= "0.0.0.0" ) )then
      tmr.alarm( 1 , 500 , 0 , launch )
    else
      -- Reset alarm again
      tmr.alarm( 0 , 2500 , 0 , checkWIFI)
      print("Checking WIFI..." .. wifiTrys)
      wifiTrys = wifiTrys + 1
    end 
  end 
end


-- Lets see if we are already connected by getting the IP
ipAddr = wifi.sta.getip()
if ( ( ipAddr == nil ) or  ( ipAddr == "0.0.0.0" ) ) then
  -- We aren't connected, so let's connect
  print("Configuring WIFI....")
  wifi.setmode( wifi.STATION )
  wifi.sta.config( SSID , APPWD)
  wifi.setphymode( WIFI_SIGNAL_MODE )
  print("Waiting for connection")
  tmr.alarm( 0 , 2500 , 0 , checkWIFI )  -- Call checkWIFI 2.5S in the future.
else
  print "Getting Temperature"
  id=0
  t=require("ds18b20")
  gpio0=4
  t.setup(gpio0)
  addrs=t.addrs()
  if (addrs ~= nil) then
    print("Total DS18B20 sensors: "..table.getn(addrs))
  end
  Temperature=t.read()
  if (Temperature < 85 ) then
    print ("Temperature: "..Temperature)
    print "Getting MAC Address"
    Mac = wifi.sta.getmac()
    Url=("GET /checkin/" .. Mac .. "/temperature/" .. Temperature .. "/ HTTP/1.1\r\n"
        .. "Host: " .. HTTPHOST .."\r\n"
        .. "Accept: */*\r\n\r\n")
    print "Connecting to HTTP. Please wait..."

    conn=net.createConnection(net.TCP, 0)
    conn:on("connection", function(c)
      conn:send(Url) 
    end)
    conn:connect(HTTPPORT,HTTPHOST)
    conn:on("receive", function(conn, payload) print(payload) end )
    conn:on("disconnection", function(conn)
      print ("Disconnecting")
      t=nil
      Temperature=nil
      ds18b20 = nil
      package.loaded["ds18b20"]=nil
      wifi.sta.disconnect()
      print ("Deep sleep")
      node.dsleep(DEEP_SLEEP,4)
      print ("Sleeping")
    end)
  else
    print ("Something went wrong with the Temperature")
  end
end
