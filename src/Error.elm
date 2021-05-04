module Error exposing (Problem(..), Context(..))

type Problem
    = ExpectingSymbol
    | ExpectingInt
    | ExpectingRightBracket
    | ExpectingPipe
    | ExpectingEscape
    | EndOfInput
    | ExpectingRawStringBegin
    | ExpectingRawStringEnd
    | ExpectingRawPrefix
    | UnHandledError Int


type Context
    = IntegerContext
    | CArgs
    | CBody
    | CArgsAndBody
    | TextExpression
