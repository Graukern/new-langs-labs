import scala.io.Source

object Main {
  def escapeXml(value: String): String =
    value
      .replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
      .replace("'", "&apos;")

  def main(args: Array[String]): Unit = {
    val path = if (args.nonEmpty) args(0) else "sample/students.csv"
    val source = Source.fromFile(path, "UTF-8")
    val lines = try source.getLines().toList finally source.close()

    if (lines.isEmpty) {
      Console.err.println("CSV-файл пустой")
      sys.exit(1)
    }

    val headers = lines.head.split(",").map(_.trim)
    val rows = lines.tail.map(_.split(",", -1).map(_.trim))

    println("<students>")
    rows.foreach { row =>
      println("  <student>")
      headers.zip(row).foreach { case (header, value) =>
        println(s"    <$header>${escapeXml(value)}</$header>")
      }
      println("  </student>")
    }
    println("</students>")
  }
}
