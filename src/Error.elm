module Error exposing (Context(..), Problem(..), EvalError(..))


type Problem
    = ExpectingSymbol
    | ExpectingChar Char
    | ExpectingInt
    | EndOfInput
    | UnHandledError Int


type Context
    = IntegerContext

type EvalError =
    IllegalOperandTypes
    | ParseErrors String
