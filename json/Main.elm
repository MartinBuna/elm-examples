module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, decodeString, int, list, string)
import Json.Decode.Pipeline exposing (decode, required)


type alias Model =
    { books : List Book
    , errorMessage : Maybe String
    }

type alias Book =
    { id : Int, title : String, author : String }

type Msg
    = SendHttpRequest
    | DataReceived (Result Http.Error (List Book))


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick SendHttpRequest ]
            [ text "Načíst knihy" ]
        , viewDataOrError model
        ]


viewDataOrError : Model -> Html Msg
viewDataOrError model =
    case model.errorMessage of
        Just message ->
            viewError message

        Nothing ->
            viewData model.books


viewError : String -> Html Msg
viewError errorMessage =
    let
        errorHeading =
            "Couldn't fetch books at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]


viewData : List Book -> Html Msg
viewData books =
    div []
        [ h3 [] [ text "Knihy:" ]
        , ul [] (List.map viewLine books)
        ]


viewLine : Book -> Html Msg
viewLine book =
    li [] [ text (toString book.id ++ " " ++ book.title ++ " " ++ book.author) ]


dataDecoder : Decoder (List Book)
dataDecoder =
    decode Book
        |> required "id" int
        |> required "title" string
        |> required "author" string
        |> list


httpCommand : Cmd Msg
httpCommand =
    dataDecoder
        |> Http.get "http://localhost:3000/posts"
        |> Http.send DataReceived


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendHttpRequest ->
            ( model, httpCommand )

        DataReceived (Ok books) ->
            ( { model | books = books }, Cmd.none )

        DataReceived (Err httpError) ->
            ( { model
                | errorMessage = Just (createErrorMessage httpError)
              }
            , Cmd.none
            )


createErrorMessage : Http.Error -> String
createErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "It appears you don't have an Internet connection right now."

        Http.BadStatus response ->
            response.status.message

        Http.BadPayload message response ->
            message


init : ( Model, Cmd Msg )
init =
    ( { books = []
      , errorMessage = Nothing
      }
    , Cmd.none
    )


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
