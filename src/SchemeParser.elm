module SchemeParser exposing (LispVal(..), expr)

import Error exposing (Context(..), Problem(..))
import Parser.Advanced as PA exposing ((|.), (|=), Parser)
import ParserTools as T
import XString


type alias Parser a =
    PA.Parser Context Problem a


type LispVal
    = Atom String
    | List (List LispVal)
    | DottedList (List LispVal) LispVal
    | Integer Int
    | String String
    | Bool Bool


{-|

    > run expr "(* 5 (+ 2 3) (u . 'v))"
    Ok (List [Atom "*",Integer 5,List [Atom "+",Integer 2,Integer 3],DottedList [Atom "u"] (List [Atom "quote",Atom "v"])])

-}
expr : Parser LispVal
expr =
    PA.oneOf [ PA.lazy (\_ -> parenthesizedList), string, atom, integer, PA.lazy (\_ -> quoted) ]


parenthesizedList : Parser LispVal
parenthesizedList =
    T.between (XString.char '(')
        (PA.oneOf [ PA.backtrackable (PA.lazy (\_ -> list)), dottedList ])
        (XString.char ')')


{-| -}
list =
    T.manySeparatedBy spaces (PA.lazy (\_ -> expr)) |> PA.map List


{-|

    > run dottedList "a . b"
    Ok (DottedList [Atom "a"] (Atom "b"))

    > run dottedList "a . 'b"
    Ok (DottedList [Atom "a"] (List [Atom "quote",Atom "b"]))

-}
dottedList : Parser LispVal
dottedList =
    dottedListHead |> PA.andThen (\h -> dottedListTail |> PA.map (\t -> DottedList [ h ] t))


dottedListHead : Parser LispVal
dottedListHead =
    T.first expr spaces


dottedListTail : Parser LispVal
dottedListTail =
    T.third (XString.char '.') spaces expr


{-|

    > run quoted "'foo"
    Ok (List [Atom "quote",Atom "foo"])

-}
quoted : Parser LispVal
quoted =
    T.second (XString.char '\'') expr |> PA.map quote


quote : LispVal -> LispVal
quote val =
    List [ Atom "quote", val ]


symbolCharacters =
    "!#$%&|*+-/:<=>?@^_~"


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


symbolPredicate c =
    String.contains (String.fromChar c) symbolCharacters


letter : Parser String
letter =
    XString.oneCharWithPredicate Char.isAlpha


spaces =
    PA.spaces


string : Parser LispVal
string =
    T.first (XString.withPredicates (\c -> c == '"') (\c -> c /= '"')) (XString.oneCharWithPredicate (\c -> c == '"'))
        |> PA.map String


atom : Parser LispVal
atom =
    XString.withPredicates atomPrefix atomBody |> PA.map makeAtom


atomPrefix c =
    symbolPredicate c || Char.isAlpha c


atomBody c =
    symbolPredicate c || Char.isAlphaNum c


makeAtom str =
    case str of
        "#t" ->
            Bool True

        "#f" ->
            Bool False

        _ ->
            Atom str


integer =
    PA.int ExpectingInt ExpectingInt |> PA.map Integer
