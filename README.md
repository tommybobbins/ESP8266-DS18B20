# DS18B20-TMP102

Read the temperature from a DS18B20 sensor and publish it to an HTTP server over WiFi.

    192.168.1.134 - - [05/Nov/2015:01:45:17 +0000] "GET /checkin/18:fe:34:f4:d2:77/temperature/13.8125/ HTTP/1.1" 200 636 "-" "-"

One more thing - LUA is integer-based and this can cause problems with conversion to Centigrade. 
I had to download and flash a floating-point-capable firmware image (nodemcu_float_*.bin) 
from https://github.com/nodemcu/nodemcu-firmware/releases.
