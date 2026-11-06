mergeSort :: [Int] -> [Int]
mergeSort [] = []
mergeSort [x] = [x]
mergeSort values =
  let middle = length values `div` 2
      (left, right) = splitAt middle values
   in merge (mergeSort left) (mergeSort right)

merge :: [Int] -> [Int] -> [Int]
merge [] right = right
merge left [] = left
merge (leftHead:leftTail) (rightHead:rightTail)
  | leftHead <= rightHead = leftHead : merge leftTail (rightHead:rightTail)
  | otherwise = rightHead : merge (leftHead:leftTail) rightTail

main :: IO ()
main = print (mergeSort [7, 2, 9, 1, 5, 3])
