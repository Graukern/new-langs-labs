# TCP-сервер турнирной таблицы на Swift

`RESULT команда1 команда2 счёт1 счёт2` регистрирует матч, а `TABLE`
показывает количество сыгранных матчей и очки. Победа даёт три очка, ничья
одно, поражение ноль. При равенстве очков команды сортируются по имени.
Таблица хранится в памяти сервера между подключениями.

## Запуск

В первом терминале WSL:

```bash
swiftc src/main.swift -o /tmp/standings
/tmp/standings server 127.0.0.1 9300
```

Во втором терминале:

```bash
/tmp/standings client 127.0.0.1 9300 'RESULT Alpha Bravo 2 1'
/tmp/standings client 127.0.0.1 9300 'RESULT Bravo Delta 0 0'
/tmp/standings client 127.0.0.1 9300 TABLE
```

После этих матчей у Alpha три очка, у Bravo и Delta по одному.
