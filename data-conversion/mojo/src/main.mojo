def main():
    var csv = "name,age\nАня,20\nИван,21"
    for line in csv.split("\n"):
        print(line.replace(",", " | "))
