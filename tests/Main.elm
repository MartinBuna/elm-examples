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
    describe "test string reverse"
        [ test "this should succeed" <|
            \() ->
                String.reverse "blah"
                    |> Expect.equal "halb"
        ]


testArrayLength : Test
testArrayLength =
    describe "test array length"
        [ test "this should succeed" <|
            \() ->
                List.length [ 1, 2 ]
                    |> Expect.equal 1
        ]
