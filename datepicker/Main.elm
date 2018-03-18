module Main exposing (..)

import Date exposing (Date)
import DatePicker exposing (DatePicker)
import Html exposing (..)


type alias Model =
    { datePicker : DatePicker, date : Maybe Date }


type Msg
    = SetDatePicker DatePicker.Msg


init : ( Model, Cmd Msg )
init =
    let
        ( datePicker, datePickerCmd ) =
            DatePicker.init
    in
    ( Model datePicker Nothing
    , Cmd.map SetDatePicker datePickerCmd
    )


view : Model -> Html Msg
view model =
    div []
        [ DatePicker.view
            model.date
            DatePicker.defaultSettings
            model.datePicker
            |> Html.map SetDatePicker
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetDatePicker msg ->
            let
                ( newDatePicker, datePickerCmd, dateEvent ) =
                    DatePicker.update DatePicker.defaultSettings msg model.datePicker

                date =
                    case dateEvent of
                        DatePicker.NoChange ->
                            model.date

                        DatePicker.Changed newDate ->
                            newDate
            in
            { model
                | datePicker = newDatePicker
                , date = date
            }
                ! [ Cmd.map SetDatePicker datePickerCmd ]


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
