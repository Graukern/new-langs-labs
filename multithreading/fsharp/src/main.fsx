open System
open System.Threading.Tasks

let upperLimit =
    match fsi.CommandLineArgs |> Array.tail with
    | [||] -> 200000
    | [| value |] ->
        match Int32.TryParse(value) with
        | true, number when number > 1 -> number
        | _ -> failwith "Верхняя граница должна быть целым числом больше 1."
    | _ -> failwith "Использование: dotnet fsi src/main.fsx [верхняя-граница]"

let isPrime number =
    if number < 2 then false
    else
        let limit = int (sqrt (float number))
        [ 2 .. limit ]
        |> List.exists (fun divisor -> number % divisor = 0)
        |> not

let ranges =
    [| 1, upperLimit / 4
       upperLimit / 4 + 1, upperLimit / 2
       upperLimit / 2 + 1, upperLimit * 3 / 4
       upperLimit * 3 / 4 + 1, upperLimit |]

let jobs =
    ranges
    |> Array.map (fun (first, last) ->
        Task.Run(fun () ->
            let count = [ first .. last ] |> List.filter isPrime |> List.length
            first, last, count))

let results = jobs |> Array.map (fun job -> job.Result)
results |> Array.iter (fun (first, last, count) ->
    printfn "Диапазон %d-%d: простых чисел: %d" first last count)

printfn "Всего простых чисел: %d" (results |> Array.sumBy (fun (_, _, count) -> count))
