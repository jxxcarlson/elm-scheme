module Top exposing (es, ps)

import Error exposing (Context(..), Problem(..))
import Eval as E
import Parser.Advanced exposing (run)
import Pretty
import SchemeParser as P exposing(LispVal)
import Either exposing(Either(..))
import EvalError exposing(EvalError(..))

type alias ParseErrors =
    List (Parser.Advanced.DeadEnd Context Problem)



es : String -> String
es input =
    case evalString input of
        Left evalError ->  Pretty.printEvalError evalError
        Right lispVal -> Pretty.printVal lispVal

ps input =
    case run P.expr input of
        Err err ->
            Pretty.printErrors err

        Ok val ->
            Pretty.printVal val



evalString :  String -> Either EvalError LispVal
evalString input =
    case run P.expr input of
        Err errors -> Left ( ParseErrors errors)
        Ok listVal -> (E.eval (Right listVal))

