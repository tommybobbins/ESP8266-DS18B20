HTTPHOST = "192.168.1.130"
HTTPPORT = 80
CLIENTID = "ESP8266-" ..  node.chipid()
MICROSECS = 950000000
--MICROSECS = 95

id=0
-- # Adafruit Huzzah GPIO #16 = NodeMCU #0 -> RESET
print "Getting Temperature"
t=require("ds18b20")
gpio0=4
t.setup(gpio0)
addrs=t.addrs()
if (addrs ~= nil) then
  print("Total DS18B20 sensors: "..table.getn(addrs))
end
Temperature=t.read()
print ("Temperature: "..Temperature)
print "Getting MAC Address"
Mac = wifi.sta.getmac()
Url=("GET /checkin/" .. Mac .. "/temperature/" .. Temperature .. "/ HTTP/1.1\r\n"
    .. "Host: " .. HTTPHOST .."\r\n"
    .. "Connection: keep-alive\r\nAccept: */*\r\n\r\n")
print "Connecting to HTTP. Please wait..."

conn=net.createConnection(net.TCP, 0)
conn:on("receive", function(conn, payload) print(payload) end )
conn:on("connection", function(c)
    conn:send(Url) 
    end)
conn:connect(HTTPPORT,HTTPHOST)

conn:on("disconnection", function(conn)
                      t=nil
                      Temperature=nil
                      ds18b20 = nil
                      package.loaded["ds18b20"]=nil
                      print("Got disconnection...")
                      print ("Deep sleep...")
                      node.dsleep(MICROSECS);
                      print ("Awake...")
     end)
