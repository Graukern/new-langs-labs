import algorithm, net, os, strutils

proc middleAverage(left, right: BiggestInt): string =
  var whole = left div 2 + right div 2
  let remainder = left mod 2 + right mod 2
  whole += remainder div 2
  if remainder mod 2 == 0:
    return $whole
  if remainder > 0:
    if whole < 0:
      if whole == -1: return "-0.5"
      return $(whole + 1) & ".5"
    return $whole & ".5"
  if whole > 0:
    return $(whole - 1) & ".5"
  if whole == 0: return "-0.5"
  return $whole & ".5"

proc serve(client: Socket) =
  var values: seq[BiggestInt]
  while true:
    let line = client.recvLine()
    if line.len == 0:
      break
    let parts = line.splitWhitespace()
    var response = "ERROR: ожидалась команда ADD <число> или MEDIAN"
    if parts.len == 2 and parts[0] == "ADD":
      try:
        values.add(parseBiggestInt(parts[1]))
        response = "OK"
      except ValueError:
        response = "ERROR: ожидалось целое число"
    elif parts == @["MEDIAN"]:
      if values.len == 0:
        response = "ERROR: список пуст"
      else:
        values.sort()
        let middle = values.len div 2
        if values.len mod 2 == 0:
          response = middleAverage(values[middle - 1], values[middle])
        else:
          response = $values[middle]
    client.send(response & "\n")

proc main() =
  if paramCount() < 3:
    quit("Использование: server|client АДРЕС ПОРТ [КОМАНДЫ...]", 1)
  let mode = paramStr(1)
  let host = paramStr(2)
  let port = parseInt(paramStr(3))
  if port notin 1..65535:
    quit("Порт должен быть в диапазоне 1–65535", 1)

  if mode == "server" and paramCount() == 3:
    let server = newSocket()
    defer: server.close()
    server.setSockOpt(OptReuseAddr, true)
    server.bindAddr(Port(port), host)
    server.listen()
    echo "Сервер слушает ", host, ":", port
    while true:
      var client: Socket
      server.accept(client)
      try:
        serve(client)
      except OSError:
        stderr.writeLine("Подключение прервано")
      finally:
        client.close()
  elif mode == "client" and paramCount() >= 4:
    let client = newSocket()
    defer: client.close()
    client.connect(host, Port(port))
    for index in 4..paramCount():
      client.send(paramStr(index) & "\n")
      let reply = client.recvLine()
      if reply.len == 0:
        quit("Сервер закрыл подключение", 1)
      echo reply
  else:
    quit("Неверные аргументы", 1)

try:
  main()
except ValueError, OSError:
  quit(getCurrentExceptionMsg(), 1)
