# Elm-Scheme

A draft implementation of a small version of a Scheme interpreter in Elm.

It follows  Jonathan Tang's article 
[Write Yourself a Scheme in 48 Hours](https://en.wikibooks.org/wiki/Write_Yourself_a_Scheme_in_48_Hours)
in which he gives a tutorial introduction to an interpreter writen in Haskell.
I plan to slowly work through the tutorial, adding features
to this little Scheme as I go.

The current goal is get a basic repl up and running.



### 4/4/2021

Start project, write the parser and a primitive `eval` function that can
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

### 4/5/2021

Introduce module `Pretty` with functions to print `LispVals`
and parse errors.  Introduce module `Top` with functions
`ps: String -> String` and `es: String -> String`.  The first
parses and displays its input.  The second parses the input,
runs eval on it, then displays the output.

```alex
> ps "'4"
"(quote 4)" 

> es "'4"
"(quote 4)" 

> ps "(+ 1 2)"
"(+ 1 2)"

> es "(+ 1 2)"
"3"
```


## Comparison with Haskell version 

Let's compare the Haskell and Elm versions of the Parser + Eval modules at the 
stage where both can provide a four function calculator.  In the [Haskell
version](https://github.com/jxxcarlson/scheme-haskell), these two modules comprise 109 lines of code. 

The Elm version is structured  a bit differently.  A total of 229 lines of 
code, where the ParserTools module does things that Haskell's Parsec
does. Excluding it, the net weight of the code is 121 lines. To my
surprise, the Elm version is only of about 11% larger at a comparable
stage of development.

```
----------------------------------------------------------------------------------
File                                blank        comment           code
----------------------------------------------------------------------------------
src/ParserTools.elm                    54             35            108
src/SchemeParser.elm                   42             27             53
src/Eval.elm                           17             10             38
src/XString.elm                        17             19             22
src/Error.elm                           4              0              8
----------------------------------------------------------------------------------
SUM:                                  134             91            229
----------------------------------------------------------------------------------

```