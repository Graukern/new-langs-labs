# HTTP-клиент на Objective-C

Программа отправляет GET-запрос по указанному адресу и печатает полученный
текст. Программа реализует клиента, а сервером для проверки служит
`python3 -m http.server`.

## Запуск

Команды рассчитаны на WSL (Ubuntu). Если инструменты ещё не установлены:

```bash
sudo apt install clang gcc libgnustep-base-dev python3
```

В первом терминале из папки `client-server/objective-c`:

```bash
python3 -m http.server 9100 --bind 127.0.0.1
```

Во втором терминале из той же папки:

```bash
clang $(gnustep-config --objc-flags) -I"$(gcc -print-file-name=include)" \
  src/main.m -o client $(gnustep-config --base-libs)
./client http://127.0.0.1:9100/README.md
```

Флаг `-I` добавляет путь к заголовкам Objective-C из GCC, включая `objc/objc.h`.
