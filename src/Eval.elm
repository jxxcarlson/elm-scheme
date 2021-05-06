module Eval exposing (..)

import Dict exposing (Dict)
import Either exposing (Either(..))
import Error exposing (Context(..), Problem(..))
import EvalError exposing (EvalError(..))
import List.Extra
import Parser.Advanced
import SchemeParser exposing (LispVal(..))


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
        Left err ->
            Left err

        Right (Atom s) ->
            Right (Atom s)

        Right (DottedList stuff v) ->
            case eval (Right v) of
                Left err ->
                    Left err

                Right v_ ->
                    Right (DottedList (mapOverList eval stuff) v_)

        Right (Integer n) ->
            Right (Integer n)

        Right (Real x) ->
            Right (Real x)

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


unwrapList : List (Either a b) -> List b
unwrapList list =
    let
        folder : Either a b -> List b -> List b
        folder e list_ =
            case e of
                Left _ ->
                    list_

                Right b ->
                    b :: list_
    in
    List.foldl folder [] list |> List.reverse


apply : String -> List LispVal -> Either EvalError LispVal
apply func args =
    --let
    --    _ =
    --        Debug.log "ARG TYPES" (List.map typeOf args)
    --in
    case List.map typeOf args of
        [ Int, Int ] ->
            evalFunction intIntPrimitives func args

        [ Float, Float ] ->
            evalFunction floatFloatPrimitives func args

        _ ->
            Left (BadArgs "Inconsistent arg types" args)


evalFunction primitives_ func args =
    case Dict.get func primitives_ of
        Just f ->
            f args

        Nothing ->
            Left (NoSuchFunction func)


intIntPrimitives : Dict String (List LispVal -> Either EvalError LispVal)
intIntPrimitives =
    Dict.fromList
        [ ( "+", intIntBinop (+) )
        , ( "-", intIntBinop (-) )
        , ( "*", intIntBinop (*) )
        , ( "/", intIntBinop (//) )

        --("mod", numericBinop mod),
        --("quotient", numericBinop quot),
        --("remainder", numericBinop rem)
        ]


floatFloatPrimitives : Dict String (List LispVal -> Either EvalError LispVal)
floatFloatPrimitives =
    Dict.fromList
        [ ( "+", floatFloatBinop (+) )
        , ( "-", floatFloatBinop (-) )
        , ( "*", floatFloatBinop (*) )
        , ( "/", floatFloatBinop (/) )
        ]


typeOf : LispVal -> EType
typeOf lispVal =
    case lispVal of
        Integer _ ->
            Int

        Real _ ->
            Float

        Bool _ ->
            Boolean

        _ ->
            Undefined


type EType
    = Int
    | Float
    | Boolean
    | Undefined


intIntBinop : (Int -> Int -> Int) -> List LispVal -> Either EvalError LispVal
intIntBinop op params =
    case
        ( getNum 0 params, getNum 1 params )
    of
        ( Right (Integer a), Right (Integer b) ) ->
            Right (Integer (op a b))

        _ ->
            Left (BadArgs "Args should be int, int" params)


floatFloatBinop : (Float -> Float -> Float) -> List LispVal -> Either EvalError LispVal
floatFloatBinop op params =
    case
        ( getNum 0 params, getNum 1 params )
    of
        ( Right (Real a), Right (Real b) ) ->
            Right (Real (op a b))

        _ ->
            Left (BadArgs "Args should be float, float" params)


getNum : Int -> List LispVal -> Either EvalError LispVal
getNum k list =
    case List.Extra.getAt k list of
        Just val ->
            Right val

        Nothing ->
            Left (MissingArg k)



--
--unpackNum : LispVal -> Maybe Int
--unpackNum val =
--    case val of
--        Integer n ->
--            Just n
--
--        String n ->
--            String.toInt n
--
--        List data ->
--            List.head data |> Maybe.andThen unpackNum
--
--        _ ->
--            Nothing
