fun climbStairs n =
    let
        val cache = Array.array (n + 1, ~1)
        fun calculate value =
            if value <= 1 then value
            else
                let
                    val saved = Array.sub (cache, value)
                in
                    if saved <> ~1 then saved
                    else
                        let
                            val result = calculate (value - 1) + calculate (value - 2)
                        in
                            Array.update (cache, value, result);
                            result
                        end
                end
    in
        calculate n
    end

val _ = print ("Вариантов для 5 ступеней: " ^ Int.toString (climbStairs 5) ^ "\n")
