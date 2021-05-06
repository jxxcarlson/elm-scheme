module EvalError exposing (EvalError(..))

import Parser.Advanced
import Error exposing(Context, Problem)

type alias ParseErrors =
    List (Parser.Advanced.DeadEnd Context Problem)

type alias ParseError =
    Parser.Advanced.DeadEnd Context Problem


type EvalError =
    ParseErrors (List ParseError)
    | NoSuchFunction String
