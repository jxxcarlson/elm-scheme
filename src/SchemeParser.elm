module SchemeParser exposing (..)


import Parser.Advanced exposing ((|.), (|=))
import XString
import Error exposing(Context(..), Problem(..))

type alias Parser a =
    Parser.Advanced.Parser Context Problem a


type LispVal = Atom String
             | List (List LispVal)
             | DottedList (List LispVal) LispVal
             | Number Int
             | String String
             | Bool Bool

symbolCharacters = "!#$%&|*+-/:<=>?@^_~"

{-|
    > run (first symbol symbol) "@+"
    Ok "@"

    > run (first symbol symbol) "@2"
    Err [{ col = 2, contextStack = [], problem = ExpectingSymbol, row = 1 }]

    > run (second spaces symbol) " @"
    Ok "@"
        : Result (List (Parser.Advanced.DeadEnd Error.Context Error.Problem)) String
    > run (second spaces symbol) " \n@"
    Ok "@"



-}
symbol : Parser String
symbol =
    XString.oneCharWithPredicate (\c -> String.contains (String.fromChar c) symbolCharacters )


spaces = Parser.Advanced.spaces