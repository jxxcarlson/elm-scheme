module XString exposing (withPredicates,  oneCharWithPredicate)

{-| Grammar:

    EscapeChar -> '|' | ''[' | ']'
    GoodChar -> any unicode character other than '|', ''[', ']'
    Text -> (GoodChar | EscapeChar)+

    NOT YET IMPLEMENTED:

    RawString -> as in Rust?
    String -> (Text|RawString)+

-}

{- (text -}

import Parser.Advanced as Parser exposing ((|.), (|=))
import Error exposing (Context(..), Problem(..))


type alias Parser a =
    Parser.Parser Context Problem a

{-| textPS = "text prefixText stopCharacters": Get the longest string
whose first character satisfies the prefixTest and whose remaining
characters are not in the list of stop characters. Example:

    line =
        textPS (\c -> Char.isAlpha) [ '\n' ]

recognizes lines that start with an alphabetic character.

-}
withPredicates : (Char -> Bool) -> (Char -> Bool) -> Parser String
withPredicates prefixTest predicate =
    Parser.succeed (\start finish content -> String.slice start finish content )
        |= Parser.getOffset
        |. Parser.chompIf (\c -> prefixTest c) (UnHandledError 2)
        |. Parser.chompWhile (\c -> predicate c)
        |= Parser.getOffset
        |= Parser.getSource


--withPredicate : (Char -> Bool) -> Parser String
--withPredicate predicate =
--    withPredicates predicate (\c -> c /= '\\' && predicate c)

oneCharWithPredicate : (Char -> Bool) -> Parser String
oneCharWithPredicate predicate =
    Parser.succeed (\start finish content -> String.slice start finish content )
        |= Parser.getOffset
        |. Parser.chompIf predicate ExpectingSymbol
        |= Parser.getOffset
        |= Parser.getSource