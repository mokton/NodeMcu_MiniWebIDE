# NodeMcu_miniWebIDE
Manage files one your NodeMcu(ESP8266) via browser.

The original code was from [ESP8266 Community Forum](http://www.esp8266.com/viewtopic.php?f=19&t=1549).
> I fixed some bugs and added some new features.
>
> If you have some new ideas, please let me know, or just upgrade it.

##How to use
Create, Edit, Run and Remove NodeMCU files using your web browser.

Examples:

  1.List all the files in the MCU
	
    http://mcu_ip/ 
		
  2.Display the file on your browser
	
    http://mcu_ip/newfile.lua 
		
  3.Create or edit the specified script in your browser
	
    http://mcu_ip/newfile.lua?edit
	
  4.Run the specified script and will show the executed result
	
    http://mcu_ip/newfile.lua?run
	
  5.Remove the specified script file
	
    http://mcu_ip/newfile.lua?remove
