module Experiment exposing (..)

import Either exposing(Either(..))
type Error = A | B

incE : Either Error Int -> Either Error Int
incE val =
    case val of
        Left err -> Left err
        Right k -> Right (k + 1)

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
