module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (checked, name, type_)
import Html.Events exposing (onClick)
import Ports exposing (..)


type Msg
    = CheckboxChange
    | StateLoaded Model


type alias Model =
    Bool

type alias Flags = Model

init : Flags -> ( Model, Cmd Msg )
init flags =
    ( flags, Cmd.none )


updateWithLocalStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithLocalStorage msg model =
    let
        ( newModel, commands ) =
            update msg model
    in
    ( newModel, Cmd.batch [ commands, saveState newModel ] )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CheckboxChange ->
            ( not model, Cmd.none )

        StateLoaded state ->
            ( state, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ text "Checkbox representing state to be stored"
        , input [ type_ "checkbox", name "cbState", checked model, onClick CheckboxChange ] []
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    loadState StateLoaded


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = updateWithLocalStorage
        , subscriptions = subscriptions
        }
