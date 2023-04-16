curl -X POST /api/connection HTTP/1.1
Host: octopi-Ender3v2.local
Content-Type: application/json
X-Api-Key: D1C5158FACC04A9585C9573CD71D9EC4

{
  "command": "connect",
  "port": "/dev/ttyACM0",
  "baudrate": 115200,
  "printerProfile": "my_printer_profile",
  "save": true,
  "autoconnect": true
}