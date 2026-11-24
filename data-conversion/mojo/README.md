# Конвертация PO в JSON на Mojo

Конвертер читает PO в UTF-8 и записывает JSON-объект из пар `msgid` и
`msgstr`. Он объединяет строки продолжения и сохраняет кавычки и переносы
строк в переводе. Поддерживаются обычные записи без контекста и множественных форм.

## Запуск

Из этой папки с установленным `uv`:

```bash
uv run --with mojo==1.2.0 mojo run src/main.mojo sample/messages.po /tmp/messages.json
cat /tmp/messages.json
```
