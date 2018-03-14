module Main exposing (..)

import AnimationFrame exposing (times)
import Dict exposing (Dict)
import Html exposing (Html, program)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Set exposing (Set)
import Time exposing (Time)


type Msg
    = NewTask Task
    | DeleteTask Task
    | FrameReceived Time


type alias Model =
    { tasks : Set Task
    , msgBuffer : Dict Task DelayedMsg
    }


type alias DelayedMsg =
    { msg : Msg
    , delay : Time
    , startTime : Time
    }


type alias Task =
    Int


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
    ( { tasks =
            Set.fromList
                [ 1
                , 2
                ]
      , msgBuffer = Dict.empty
      }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.div [ class "tasks" ] (viewTasks model)
        , Html.div []
            [ Html.button [ onClick (NewTask (getMaxTask model.tasks)) ] [ Html.text "nový úkol" ] ]
        ]


viewTasks : Model -> List (Html Msg)
viewTasks model =
    let
        newTasks =
            Set.union model.tasks (Set.fromList (Dict.keys model.msgBuffer))
    in
    List.map (viewTask model.msgBuffer) (Set.toList newTasks)


viewTask : Dict Task DelayedMsg -> Task -> Html Msg
viewTask msgBuffer task =
    let
        msgFromBuffer =
            Dict.get task msgBuffer
    in
    case msgFromBuffer of
        Just msg ->
            Html.div [ class (getTaskTransitionClass msg) ]
                [ Html.text (toString task ++ ". úkol")
                , Html.button [] [ Html.text "-" ]
                ]

        Maybe.Nothing ->
            Html.div [ class "showing" ]
                [ Html.text (toString task ++ ". úkol")
                , Html.button [ onClick (DeleteTask task) ] [ Html.text "-" ]
                ]


getTaskTransitionClass : DelayedMsg -> String
getTaskTransitionClass msg =
    case msg.msg of
        NewTask task ->
            "hidden"

        DeleteTask task ->
            "hiding"

        _ ->
            ""


mapTasksFromBuffer : DelayedMsg -> Maybe Task
mapTasksFromBuffer delayedMsg =
    case delayedMsg.msg of
        NewTask task ->
            Just task

        DeleteTask task ->
            Just task

        _ ->
            Maybe.Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewTask task ->
            ( { model
                | msgBuffer = Dict.insert task { msg = NewTask task, delay = 0, startTime = 0 } model.msgBuffer
                , tasks = Set.insert task model.tasks
              }
            , Cmd.none
            )

        DeleteTask task ->
            ( { model
                | msgBuffer = Dict.insert task { msg = DeleteTask task, delay = 500, startTime = 0 } model.msgBuffer
                , tasks = Set.remove task model.tasks
              }
            , Cmd.none
            )

        FrameReceived time ->
            let
                msgBuffer =
                    Dict.map fromMaybe (Dict.filter leaveOnlyJust (Dict.map (solveMsgBuffer time) model.msgBuffer))
            in
            ( { model | msgBuffer = msgBuffer }, Cmd.none )


fromMaybe : Task -> Maybe DelayedMsg -> DelayedMsg
fromMaybe task msg =
    case msg of
        Just x ->
            x

        _ ->
            { msg = FrameReceived 0
            , delay = 0
            , startTime = 0
            }


leaveOnlyJust : Task -> Maybe v -> Bool
leaveOnlyJust task msg =
    case msg of
        Just x ->
            True

        Maybe.Nothing ->
            False


solveMsgBuffer : Time -> Task -> DelayedMsg -> Maybe DelayedMsg
solveMsgBuffer time task delayedMsg =
    case delayedMsg.msg of
        NewTask task ->
            Maybe.Nothing

        DeleteTask task ->
            if delayedMsg.startTime == 0 then
                Just { delayedMsg | startTime = time }
            else if (time - delayedMsg.startTime) > delayedMsg.delay then
                Maybe.Nothing
            else
                Just delayedMsg

        _ ->
            Maybe.Nothing


getMaxTask : Set Task -> Task
getMaxTask tasks =
    Set.foldr max 0 tasks + 1


subscriptions : Model -> Sub Msg
subscriptions model =
    case Dict.size model.msgBuffer of
        0 ->
            Sub.none

        _ ->
            times FrameReceived
