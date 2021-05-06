module Error exposing (Context(..), Problem(..))


type Problem
    = ExpectingSymbol
    | ExpectingChar Char
    | ExpectingInt
    | ExpectingFloat
    | EndOfInput
    | UnHandledError Int


type Context
    = IntegerContext
