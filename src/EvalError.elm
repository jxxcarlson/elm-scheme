module EvalError exposing (EvalError(..))

import Error exposing (Context, Problem)
import Parser.Advanced
import SchemeParser exposing (LispVal)


type alias ParseErrors =
    List (Parser.Advanced.DeadEnd Context Problem)


type alias ParseError =
    Parser.Advanced.DeadEnd Context Problem


type EvalError
    = ParseErrors (List ParseError)
    | BadArgs String (List LispVal)
    | MissingArg Int
    | NoSuchFunction String
