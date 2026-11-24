# HTTP-клиент для расчёта корзины на Objective-C

Клиент читает корзину из файла JSON и отправляет её запросом
`POST /checkout`. Тестовый сервер считает стоимость по ценам в копейках
и количеству товаров. Клиент выводит поле `total_kopecks` из ответа.

## Запуск

В первом терминале WSL (Ubuntu) из этой папки:

```bash
python3 sample/server.py
```

Во втором терминале из этой же папки:

```bash
clang $(gnustep-config --objc-flags) -I"$(gcc -print-file-name=include)" src/main.m -o /tmp/checkout-client $(gnustep-config --base-libs)
/tmp/checkout-client http://127.0.0.1:9100/checkout sample/basket.json
```

Для сборки нужны `clang`, `gcc` и `libgnustep-base-dev`. Результат
для примера — «Итого: 530 коп.».
