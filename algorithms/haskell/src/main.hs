import System.Environment (getArgs)
import System.Exit (die)

decimalDigit :: Char -> Bool
decimalDigit character = character >= '0' && character <= '9'

parseCommands :: Bool -> String -> Either String (String, String)
parseCommands nested = collect []
  where
    collect chunks []
      | nested = Left "Не хватает закрывающей скобки."
      | otherwise = Right (concat (reverse chunks), [])
    collect chunks input@(character : rest)
      | character == ']' =
          if nested
            then Right (concat (reverse chunks), rest)
            else Left "Лишняя закрывающая скобка."
      | elem character "FLR" = collect ([character] : chunks) rest
      | decimalDigit character = do
          let (digits, suffix) = span decimalDigit input
              count = read digits :: Integer
          case suffix of
            '[' : block | count > 0 -> do
              (commands, remaining) <- parseCommands True block
              let expanded = if null commands then "" else repeatBlock count commands
              collect (expanded : chunks) remaining
            _ -> Left "Ожидалось положительное число перед открывающей скобкой."
      | otherwise = Left ("Неизвестная команда: " ++ [character])

repeatBlock :: Integer -> String -> String
repeatBlock count commands
  | count <= 0 = ""
  | otherwise = commands ++ repeatBlock (count - 1) commands

main :: IO ()
main = do
  args <- getArgs
  case args of
    [input] -> either die (putStrLn . fst) (parseCommands False input)
    _ -> die "Использование: runghc src/main.hs СТРОКА"
