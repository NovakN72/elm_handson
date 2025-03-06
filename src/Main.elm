port module Main exposing (..)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import String
import Time


type alias Model =
    { currentTime : Maybe Time.Posix }


init : ( Model, Cmd msg )
init =
    ( { currentTime = Nothing }, Cmd.none )


type Msg
    = CalculateTime --Send order to worker
    | ReturnTime (Maybe Time.Posix) --Receive the calculated data from Worker


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CalculateTime ->
            ( model, calculateTimeInWorker model )

        ReturnTime (Just wantedTime) ->
            ( { model | currentTime = Just wantedTime }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick CalculateTime ] [ text "Calculate the time!" ]
        , div []
            [ text <|
                case model.currentTime of
                    Just t ->
                        String.fromInt (Time.toHour Time.utc t)

                    Nothing ->
                        "No data yet!"
            ]
        ]



--literally the same signature as in -port:


subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveTimeFromPort ReturnTime



--Out-port : sending data out to worker:


port calculateTimeInWorker : Model -> Cmd msg



--In_port : getting data from worker:


port receiveTimeFromPort : (Maybe Time.Posix -> msg) -> Sub msg


main : Program () Model Msg
main =
    Browser.element { init = \_ -> init, update = update, view = view, subscriptions = subscriptions }
