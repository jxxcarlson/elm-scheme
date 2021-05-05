module Top exposing (es, ps)

import Error exposing (Context(..), Problem(..))
import Eval as E
import Parser.Advanced exposing (run)
import Pretty
import SchemeParser as P


type alias ParseErrors =
    List (Parser.Advanced.DeadEnd Context Problem)


es input =
    evalString input |> Pretty.printResult


ps input =
    case run P.expr input of
        Err err ->
            Pretty.printErrors err

        Ok val ->
            Pretty.printVal val



-- Pretty.printVal


evalString : String -> Result ParseErrors P.LispVal
evalString input =
    run P.expr input |> Result.map E.eval
