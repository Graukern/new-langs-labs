# Конвертация CSV в таблицу на Mojo

Программа берёт несколько CSV-строк и печатает их в виде простой таблицы.

## Установка Mojo

Mojo не входит в стандартные пакеты Ubuntu. Установите официальный Modular
toolchain по инструкции: <https://docs.modular.com/mojo/manual/get-started/>.

## Запуск

Из этой папки:

```bash
uv run --with mojo mojo run src/main.mojo
```

Проверено на Mojo 1.2.0.
