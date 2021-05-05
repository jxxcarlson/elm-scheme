module Repl exposing (helpText, transform)

import Top


transform : String -> String
transform input_ =
    Top.es (String.trim input_)



-- HELP TEXT


helpText =
    """Commands:

    :help             help
    :get FILE         load FILE into memory, apply BlackBox.transform to it
    :show             show contents of memory
    :head             first five lines of memory
    :tail             last five lines of memory
    :calc             apply BlackBox.transform to the contents of memory

    STRING            apply BlackBox.transform to STRING

Example using the default BlackBox:

    > :help                 # show help screen

    > (+ 2 3)              # apply transform to "(+ 2 3)"
    5

    > :get src/repl.js      # load file into memory and apply transform to it
    42, 97, 863

    > :calc                 # calculate: pply transform to contents of memory
    42, 97, 863
"""
