import java.nio.charset.StandardCharsets.UTF_8
import java.nio.file.{Files, Paths}
import java.time.{Instant, ZoneOffset}
import java.time.format.{DateTimeFormatter, DateTimeParseException}
import java.util.UUID
import scala.collection.JavaConverters._
import scala.util.control.NonFatal

object Main {
  case class Event(title: String, start: Instant, end: Instant)

  val calendarTime = DateTimeFormatter.ofPattern("uuuuMMdd'T'HHmmss'Z'").withZone(ZoneOffset.UTC)

  def parseTime(value: String): Instant = {
    if (!value.matches("[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-5][0-9]Z")) {
      throw new IllegalArgumentException("ожидались дата и время в UTC с точностью до секунды")
    }
    try {
      Instant.parse(value)
    } catch {
      case _: DateTimeParseException => throw new IllegalArgumentException("некорректная дата или время")
    }
  }

  def parseEvent(line: String): Event = line.split("\t", -1) match {
    case Array(title, startText, endText) if title.trim.nonEmpty =>
      val start = parseTime(startText)
      val end = parseTime(endText)
      require(end.isAfter(start), "окончание должно быть позже начала")
      Event(title, start, end)
    case _ =>
      throw new IllegalArgumentException("ожидались название, начало и окончание через табуляцию")
  }

  def escapeTitle(title: String): String =
    title.replace("\\", "\\\\").replace(",", "\\,").replace(";", "\\;")

  def foldLine(line: String): String = {
    val result = new java.lang.StringBuilder
    var index = 0
    var byteCount = 0
    while (index < line.length) {
      val point = line.codePointAt(index)
      val characters = new String(Character.toChars(point))
      val length = characters.getBytes(UTF_8).length
      if (byteCount + length > 75) {
        result.append("\r\n ")
        byteCount = 1
      }
      result.append(characters)
      index += characters.length
      byteCount += length
    }
    result.toString
  }

  def render(events: Seq[Event]): String = {
    val timestamp = calendarTime.format(Instant.now())
    val eventLines = events.flatMap { event =>
      Seq("BEGIN:VEVENT", "UID:" + UUID.randomUUID().toString, "DTSTAMP:" + timestamp,
          "DTSTART:" + calendarTime.format(event.start), "DTEND:" + calendarTime.format(event.end),
          "SUMMARY:" + escapeTitle(event.title), "END:VEVENT")
    }
    (Seq("BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//New Languages Labs//Schedule//EN") ++
      eventLines ++ Seq("END:VCALENDAR")).map(foldLine).mkString("", "\r\n", "\r\n")
  }

  def main(args: Array[String]): Unit = {
    if (args.length != 2) {
      Console.err.println("Использование: Main РАСПИСАНИЕ.tsv КАЛЕНДАРЬ.ics")
      sys.exit(1)
    }
    try {
      val input = Paths.get(args(0))
      val output = Paths.get(args(1))
      require(!Files.exists(output) || !Files.isSameFile(input, output), "пути должны различаться")
      val events = Files.readAllLines(input, UTF_8).asScala.zipWithIndex.map {
        case (line, index) =>
          try {
            parseEvent(line)
          } catch {
            case error: IllegalArgumentException =>
              throw new IllegalArgumentException("Строка " + (index + 1) + ": " + error.getMessage)
          }
      }
      require(events.nonEmpty, "расписание пусто")
      Files.write(output, render(events).getBytes(UTF_8))
    } catch {
      case NonFatal(error) =>
        Console.err.println(error.getMessage)
        sys.exit(1)
    }
  }
}
