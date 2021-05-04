module Error exposing (Problem(..), Context(..))

type Problem
    = ExpectingSymbol
    | ExpectingLeftBracket
    | ExpectingRightBracket
    | ExpectingPipe
    | ExpectingEscape
    | EndOfInput
    | ExpectingRawStringBegin
    | ExpectingRawStringEnd
    | ExpectingRawPrefix
    | UnHandledError Int


type Context
    = CElement
    | CArgs
    | CBody
    | CArgsAndBody
    | TextExpression
