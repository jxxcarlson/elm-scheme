module Error exposing (Problem(..), Context(..))

type Problem
    = ExpectingSymbol
    | ExpectingInt
      | EndOfInput
      | UnHandledError Int


type Context
    = IntegerContext

