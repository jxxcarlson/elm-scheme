# Elm-Scheme

A draft implementation of a small version of Scheme following 
Jonathan Tang's article 
[Write Yourself a Scheme in 48 Hours](https://en.wikibooks.org/wiki/Write_Yourself_a_Scheme_in_48_Hours).

4/4/2021: Start project, write the parser and a primitive `eval` function that can
do basic integer arithmetic.


```lisp
> run expr "(* 5 (+ 2 3) (u . 'v))"
    Ok (List [
      Atom "*"
    , Integer 5
    , List [Atom "+", Integer 2, Integer 3]
    , DottedList [Atom "u"] (List [Atom "quote", Atom "v"])])
  
> run expr "(* 2 (+ 3 2))" |> Result.map eval
    Ok (Integer 10)

```
