# NodeMcu_miniWebIDE
Manage files one your NodeMcu(ESP8266) via browser.
The original code was from http://www.esp8266.com/viewtopic.php?f=19&t=1549.
I fixed some bugs and added some new features.
---------------------------------------------------------------------------
Create, Edit, Run and Remove NodeMCU files using your web browser.
Examples:
http://<mcu_ip>/                     will list all the files in the MCU
http://<mcu_ip>/newfile.lua          displays the file on your browser
http://<mcu_ip>/newfile.lua?edit     allows to creates or edits the specified script in your browser
http://<mcu_ip>/newfile.lua?run      it will run the specified script and will show the executed result
http://<mcu_ip>/newfile.lua??remove  it will remove the specified script file
