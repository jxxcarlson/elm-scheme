module Eval exposing (..)

import Dict exposing (Dict)
import List.Extra
import Error exposing(Context(..),  Problem(..))
import EvalError exposing (EvalError(..))
import SchemeParser exposing (LispVal(..))
import Either exposing(Either(..))
import Parser.Advanced

-- type EvalResult = Either EvalError LispVal



type alias ParseError =
    Parser.Advanced.DeadEnd Context Problem

{-|

    > run expr "(+ 1 2)" |> Result.map eval
    Ok (Integer 3)

    > run expr "(* 2 (+ 3 2))" |> Result.map eval
    Ok (Integer 10)

-}
eval : Either EvalError LispVal -> Either EvalError LispVal
eval result =
    case result of
        Left err -> Left err

        Right (Atom s) ->
            Right (Atom s)

        Right (DottedList stuff  v) ->
            case eval (Right v) of
                Left err -> Left err
                Right v_ ->
                   Right (DottedList (mapOverList eval stuff) (v_))

        Right (Integer n) ->
            Right (Integer n)

        Right (String s) ->
            Right (String s)

        Right (Bool s) ->
            Right (Bool s)

        Right (List [ Atom "quote", val_ ]) ->
           Right (List [ Atom "quote", val_ ])

        Right (List ((Atom func) :: args)) ->
            Right (apply func (mapOverList eval args))

        Right (List items) ->
              Right (List (mapOverList eval items))


-- conjugate : (Either a b -> Either a c)

mapOverList : (Either a b -> Either a c) -> List b -> List c
mapOverList f list =
    List.map f (List.map Right list) |> unwrapList


unwrapList : List(Either a b)-> List b
unwrapList list =
    let
        folder : (Either a b) -> List b -> List b
        folder e list_ =
            case e of
                Left _ -> list_
                Right b -> b :: list_
    in
    List.foldl folder [] list |> List.reverse

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
