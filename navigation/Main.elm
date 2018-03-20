module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onWithOptions)
import Json.Decode as Decode
import Navigation
import UrlParser


type Msg
    = ChangeLocation String
    | OnLocationChange Navigation.Location


type alias Model =
    Route


type Route
    = FirstPage
    | SecondPage
    | NotFoundRoute


matchers : UrlParser.Parser (Route -> a) a
matchers =
    UrlParser.oneOf
        [ UrlParser.map FirstPage UrlParser.top
        , UrlParser.map SecondPage (UrlParser.s "druha")
        ]


parseLocation : Navigation.Location -> Route
parseLocation location =
    case UrlParser.parsePath matchers location of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeLocation path ->
            ( model, Navigation.newUrl path )

        OnLocationChange location ->
            ( parseLocation location, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ nav model
        , page model
        ]


onLinkClick : msg -> Attribute msg
onLinkClick message =
    let
        options =
            { stopPropagation = False
            , preventDefault = True
            }
    in
    onWithOptions "click" options (Decode.succeed message)


nav : Model -> Html Msg
nav model =
    div []
        [ a [ href "/", onLinkClick (ChangeLocation "/") ] [ text "První stránka" ]
        , text " "
        , a [ href "druha", onLinkClick (ChangeLocation "druha") ] [ text "Druhá stránka" ]
        ]


page : Model -> Html Msg
page model =
    case model of
        FirstPage ->
            text "První stránka"

        SecondPage ->
            text "Druhá stránka"

        NotFoundRoute ->
            text "Not Found"


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( parseLocation location, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
