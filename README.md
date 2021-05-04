# Elm-Scheme

A draft implementation of a small version of Scheme following 
Jonathan Tang's article 
[Write Yourself a Scheme in 48 Hours](https://en.wikibooks.org/wiki/Write_Yourself_a_Scheme_in_48_Hours).

4/4/2021: Start project and write the parser


```lisp
> run expr "(* 5 (+ 2 3) (u . 'v))"
Ok (List [
    Atom "*"
  , Integer 5
  , List [Atom "+", Integer 2, Integer 3]
  , DottedList [Atom "u"] (List [Atom "quote", Atom "v"])])

```
