open System
open System.Globalization
open System.IO
open System.Threading.Tasks

let summarize (path: string) =
    let name = Path.GetFileName(path)
    try
        let temperatures =
            File.ReadLines(path)
            |> Seq.mapi (fun index line ->
                match Int32.TryParse(line, NumberStyles.Integer, CultureInfo.InvariantCulture) with
                | true, temperature -> temperature
                | false, _ -> failwithf "некорректное показание в строке %d" (index + 1))
            |> Seq.toArray

        if Array.isEmpty temperatures then
            Error (sprintf "%s: файл пуст" name)
        else
            let average = temperatures |> Array.averageBy float
            Ok (sprintf "%s: показаний %d, минимум %d, максимум %d, средняя %.2f °C"
                    name temperatures.Length (Array.min temperatures)
                    (Array.max temperatures) average)
    with error ->
        Error (sprintf "%s: %s" name error.Message)

let paths = fsi.CommandLineArgs |> Array.skip 1
if paths.Length < 2 then
    eprintfn "Использование: dotnet fsi src/main.fsx ФАЙЛ1 ФАЙЛ2 [ФАЙЛЫ...]"
    exit 1

let tasks = paths |> Array.map (fun path -> Task.Run(fun () -> summarize path))
let results = Task.WhenAll(tasks).GetAwaiter().GetResult()
let mutable failed = false
for result in results do
    match result with
    | Ok summary -> printfn "%s" summary
    | Error message ->
        failed <- true
        eprintfn "%s" message

if failed then exit 1
