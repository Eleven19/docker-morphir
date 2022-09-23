module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


suite : Test
suite =
    describe "Example tests"
    [ test "Always passes" <|
        \_ -> 1 |> Expect.equal 1
    ]
