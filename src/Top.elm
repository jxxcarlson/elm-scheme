module Top exposing (es, ps)

import Error exposing (Context(..), Problem(..))
import Eval as E
import Parser.Advanced exposing (run)
import Pretty
import SchemeParser as P
import Either exposing(Either(..))

type alias ParseErrors =
    List (Parser.Advanced.DeadEnd Context Problem)


es input = evalString input


ps input =
    case run P.expr input of
        Err err ->
            Pretty.printErrors err

        Ok val ->
            Pretty.printVal val



-- Pretty.printVal

evalString :  String -> Either String String
evalString input =
    case run P.expr input of
        Err errors -> Left (Pretty.printErrors errors)
        Ok listVal -> Either.mapBoth (\errors -> "Eval error") Pretty.printVal (E.eval (Right listVal))

