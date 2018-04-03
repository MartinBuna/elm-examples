module HtmlRunnerExample exposing (..)

{-| HOW TO RUN THIS EXAMPLE

1.  Run elm-reactor from the same directory as your tests' elm-package.json. (For example, if you have tests/elm-package.json, then cd into tests/ and
    run elm-reactor.)
2.  Visit <http://localhost:8000> and bring up this file.

-}

import Expect
import String
import Test exposing (..)
import Test.Runner.Html


main : Test.Runner.Html.TestProgram
main =
    [ testStringReverse
    , testArrayLength
    ]
        |> concat
        |> Test.Runner.Html.run


testStringReverse : Test
testStringReverse =
    describe "Otestování funkce String.reverse."
        [ test "Toto by mělo projít." <|
            \() ->
                String.reverse "abcd"
                    |> Expect.equal "dcba"
        , test "Toto by mělo selhat." <|
            \() ->
                String.reverse "abcd"
                    |> Expect.equal "acdb"
        ]


testArrayLength : Test
testArrayLength =
    describe "Otestování funkce List.length."
        [ test "Toto by mělo selhat." <|
            \() ->
                List.length [ 1, 2 ]
                    |> Expect.equal 1
        ]
