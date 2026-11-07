# Конвертация CSV в XML на Scala

Программа читает простой CSV-файл с заголовком и переводит его в XML.

## Запуск

```bash
mkdir -p out
scalac -d out src/Main.scala
scala -nocompdaemon -cp out Main sample/students.csv
```

Результат печатается в консоль.
