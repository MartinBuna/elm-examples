module Main exposing (..)

import Html exposing (Html, program)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


type Msg
    = Change


type alias Model =
    Bool


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( True
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    Html.div [ class ("circle " ++ getTransitionClass model), onClick Change ]
        []


getTransitionClass : Bool -> String
getTransitionClass state =
    case state of
        True ->
            "shown"

        False ->
            "hidden"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Change ->
            not model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
