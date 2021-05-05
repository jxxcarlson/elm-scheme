module Error exposing (Context(..), Problem(..))


type Problem
    = ExpectingSymbol
    | ExpectingChar Char
    | ExpectingInt
    | EndOfInput
    | UnHandledError Int


type Context
    = IntegerContext
