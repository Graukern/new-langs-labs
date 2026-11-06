defmodule ParallelSquares do
  def run(limit) when limit > 0 do
    parent = self()

    1..limit
    |> Enum.each(fn number ->
      spawn(fn -> send(parent, {:square, number, number * number}) end)
    end)

    collect(limit, 0)
  end

  defp collect(0, total), do: total

  defp collect(left, total) do
    receive do
      {:square, _number, value} -> collect(left - 1, total + value)
    end
  end
end

limit =
  case System.argv() do
    [] -> 10
    [value] -> String.to_integer(value)
    _ -> 0
  end

if limit > 0 do
  IO.puts("Сумма квадратов от 1 до #{limit}: #{ParallelSquares.run(limit)}")
else
  IO.puts("Использование: elixir src/main.exs [положительное-число]")
  System.halt(1)
end
