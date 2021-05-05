module Top exposing (es, evalString)

import Error exposing (Context(..), Problem(..))
import Eval as E
import Parser.Advanced exposing (run)
import SchemeParser as P


type alias ParseErrors =
    List (Parser.Advanced.DeadEnd Context Problem)


es =
    evalString


evalString : String -> Result ParseErrors P.LispVal
evalString input =
    run P.expr input |> Result.map E.eval
