port module Ports exposing (..)

port saveState : Bool -> Cmd msg

port loadState : (Bool -> msg) -> Sub msg