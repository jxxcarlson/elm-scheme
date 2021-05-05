module Pretty exposing (printErrors, printResult, printVal)

import Error exposing (Context(..), Problem(..))
import Parser.Advanced
import SchemeParser exposing (LispVal(..))


type alias ParseError =
    Parser.Advanced.DeadEnd Context Problem


printResult : Result (List ParseError) LispVal -> String
printResult result =
    case result of
        Err err ->
            printErrors err

        Ok val ->
            printVal val


printErrors : List ParseError -> String
printErrors errors =
    List.map printError errors |> String.join "\n"


printError : ParseError -> String
printError err =
    case err.problem of
        ExpectingChar ')' ->
            "Missing ')' in row " ++ String.fromInt err.row ++ ", column " ++ String.fromInt err.col

        _ ->
            "Parse error"


printVal : LispVal -> String
printVal val =
    case val of
        Atom str ->
            str

        List data ->
            "(" ++ (List.map printVal data |> String.join " ") ++ ")"

        DottedList data val_ ->
            "(" ++ ((List.map printVal data |> String.join " ") ++ " . " ++ printVal val_) ++ ")"

        Integer k ->
            String.fromInt k

        String str ->
            str

        Bool b ->
            if b then
                "#t"

            else
                "#f"
