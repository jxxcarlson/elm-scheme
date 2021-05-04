module SchemeParser exposing (..)


import Parser.Advanced as PA exposing (Parser, (|.), (|=))
import XString
import Error exposing(Context(..), Problem(..))
import ParserTools as T

type alias Parser a =
    PA.Parser Context Problem a


type LispVal = Atom String
             | List (List LispVal)
             | DottedList (List LispVal) LispVal
             | Integer Int
             | String String
             | Bool Bool


expr = PA.oneOf [string, atom, integer]

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
    XString.oneCharWithPredicate symbolPredicate

symbolPredicate c = String.contains (String.fromChar c) symbolCharacters

letter : Parser String
letter = XString.oneCharWithPredicate Char.isAlpha

spaces = PA.spaces


string : Parser LispVal
string =
        T.first (XString.withPredicates (\c -> c == '"') (\c -> c /= '"')) (XString.oneCharWithPredicate (\c -> c == '"'))
          |> PA.map String


atom : Parser LispVal
atom = XString.withPredicates  atomPrefix atomBody |> PA.map makeAtom


atomPrefix c =  (symbolPredicate c || Char.isAlpha c)

atomBody c =  (symbolPredicate c || Char.isAlphaNum c)

makeAtom str =
    case str of
        "#t" -> Bool True
        "#f" -> Bool False
        _ -> Atom str


integer =
    PA.int ExpectingInt ExpectingInt |> PA.map Integer

