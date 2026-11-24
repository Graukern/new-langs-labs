# Экспорт расписания из TSV в iCalendar на Scala

Каждая строка UTF-8 файла содержит название события, начало и окончание.
Поля разделены табуляцией. Время передаётся в UTC в формате
`2026-12-01T10:00:00Z`. Программа записывает одно событие на строку
в файл iCalendar.

## Запуск

Из этой папки со Scala 2.11:

```bash
mkdir -p out
scalac -d out src/Main.scala
scala -cp out Main sample/schedule.tsv /tmp/schedule.ics
```

В файле из примера два события.
