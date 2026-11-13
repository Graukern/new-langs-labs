# HTTP-клиент на Objective-C

Программа отправляет GET-запрос по указанному адресу и печатает полученный
текст. Программа реализует клиента, а сервером для проверки служит
`python3 -m http.server`.

## Запуск

В одной папке с тестовым файлом:

```bash
python3 -m http.server 9100
```

В другом терминале:

```bash
clang `gnustep-config --objc-flags` src/main.m -o client \
  `gnustep-config --base-libs`
./client http://127.0.0.1:9100/README.md
```
