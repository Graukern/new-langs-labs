from python import Python


fn main() raises:
    let csv = Python.import_module("csv")
    let path = Python.import_module("pathlib").Path("sample/students.csv")

    var rows = csv.reader(path.open())
    for row in rows:
        print(" | ".join(row))
