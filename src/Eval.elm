module Eval exposing (..)

import  SchemeParser exposing(LispVal(..))
import Dict exposing(Dict)


{-|

-}
eval : LispVal -> LispVal
eval val =
    case val of
        List items -> List (List.map eval items)
        Atom s -> Atom s
        -- DottedList (List items) v -> DottedList (List (List.map eval items)) (eval v)
        DottedList stuff v -> DottedList (List.map eval stuff) (eval v)
        Integer n -> Integer n
        String s -> String s
        Bool s -> Bool s




primitives :  Dict String (List LispVal -> LispVal)
primitives = [("+", numericBinop (+)),
              --("-", numericBinop (-)),
              --("*", numericBinop (*)),
              --("/", numericBinop div),
              --("mod", numericBinop mod),
              --("quotient", numericBinop quot),
              --("remainder", numericBinop rem)
              ]