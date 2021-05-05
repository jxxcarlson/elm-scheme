module Eval exposing (..)

import Dict exposing (Dict)
import List.Extra
import SchemeParser exposing (LispVal(..))


{-|

    > run expr "(+ 1 2)" |> Result.map eval
    Ok (Integer 3)

    > run expr "(* 2 (+ 3 2))" |> Result.map eval
    Ok (Integer 10)

-}
eval : LispVal -> LispVal
eval val =
    case val of
        Atom s ->
            Atom s

        DottedList stuff v ->
            DottedList (List.map eval stuff) (eval v)

        Integer n ->
            Integer n

        String s ->
            String s

        Bool s ->
            Bool s

        List [ Atom "quote", val_ ] ->
            List [ Atom "quote", val_ ]

        List ((Atom func) :: args) ->
            apply func (List.map eval args)

        List items ->
            List (List.map eval items)


apply : String -> List LispVal -> LispVal
apply func args =
    case Dict.get func primitives of
        Just f ->
            f args

        Nothing ->
            Atom ("No function named " ++ func)


primitives : Dict String (List LispVal -> LispVal)
primitives =
    Dict.fromList
        [ ( "+", numericBinop (+) )
        , ( "-", numericBinop (-) )
        , ( "*", numericBinop (*) )
        , ( "/", numericBinop (//) )

        --("mod", numericBinop mod),
        --("quotient", numericBinop quot),
        --("remainder", numericBinop rem)
        ]


numericBinop : (Int -> Int -> Int) -> List LispVal -> LispVal
numericBinop op params =
    Integer <| op (getNum 0 params) (getNum 1 params)


getNum : Int -> List LispVal -> Int
getNum k list =
    List.Extra.getAt k list |> Maybe.map unpackNum |> Maybe.withDefault 0


unpackNum : LispVal -> Int
unpackNum val =
    case val of
        Integer n ->
            n

        String n ->
            String.toInt n |> Maybe.withDefault 0

        List data ->
            List.head data |> Maybe.map unpackNum |> Maybe.withDefault 0

        _ ->
            0



-- Number $ foldl1 op $ map unpackNum params
