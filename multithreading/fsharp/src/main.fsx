open System
open System.Threading.Tasks

let values =
    match fsi.CommandLineArgs |> Array.tail with
    | [||] -> [| "first"; "second"; "third"; "fourth" |]
    | args -> args

let jobs =
    values
    |> Array.map (fun value ->
        Task.Run(fun () -> value, value.Length))

let total =
    jobs
    |> Array.sumBy (fun job -> snd job.Result)

printfn "Элементов: %d" values.Length
printfn "Общая длина: %d" total
