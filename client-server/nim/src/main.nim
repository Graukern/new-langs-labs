import net
import os
import strutils

if paramCount() < 1:
  quit("Использование: server|client [host] [port] [сообщение]", 1)

let mode = paramStr(1)
let host = if paramCount() >= 2: paramStr(2) else: "127.0.0.1"
let port = if paramCount() >= 3: Port(parseInt(paramStr(3))) else: Port(9000)

if mode == "server":
  let server = newSocket()
  server.bindAddr(port, host)
  server.listen()
  echo "Сервер слушает ", host, ":", port

  var client = newSocket()
  var address = ""
  server.acceptAddr(client, address)
  echo "Подключение: ", address
  let message = client.recvLine()
  client.send(message & "\n")
  client.close()
  server.close()
elif mode == "client":
  if paramCount() < 4:
    quit("Для клиента нужно передать сообщение", 1)
  let client = newSocket()
  client.connect(host, port)
  client.send(paramStr(4) & "\n")
  echo "Ответ сервера: ", client.recvLine()
  client.close()
else:
  quit("Неизвестный режим: " & mode, 1)
