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
            apply func (mapOverList eval args)

        Right (List items) ->
              Right (List (mapOverList eval items))



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

apply : String -> List LispVal -> Either EvalError LispVal
apply func args =
    case Dict.get func primitives of
        Just f ->
            f args

        Nothing ->
            Left ( NoSuchFunction func)


primitives : Dict String (List LispVal -> Either EvalError LispVal)
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


numericBinop : (Int -> Int -> Int) -> List LispVal -> Either EvalError LispVal
numericBinop op params =
    case
      (getNum 0 params, getNum 1 params) of
          (Right (Integer a), Right (Integer b)) -> Right (Integer (op a b))
          _ -> Left (BadArgs params)



getNum : Int -> List LispVal -> Either EvalError LispVal
getNum k list =
    case List.Extra.getAt k list of
        Just val -> Right val
        Nothing -> Left (BadArgs list)

unpackNum : LispVal -> Maybe Int
unpackNum val =
    case val of
        Integer n ->
            Just n

        String n ->
            String.toInt n

        List data ->
            List.head data |> Maybe.andThen unpackNum

        _ ->
            Nothing

