-- Constants

CMDFILE = "httppost.lua"   -- File that is executed after connection

-- Change the code of this function that it calls your code.
function launch()
  print ("Calling CMDFILE")
  dofile(CMDFILE)
end

print("-- Starting up! ")
tmr.delay(30000000)

print("-- About to launch code! ")
tmr.alarm(0, 10000, 1, function() 
  -- Call our CMDFILE every 10 seconds
  print ("Launch code")
  launch()
end )
-- Drop through here to let NodeMcu run
print ("We should never get here")
