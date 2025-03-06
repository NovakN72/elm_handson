module TimeWorker exposing (..)

import Main exposing (Model)
import Platform
import Task
import Time exposing (Posix)


type Msg
    = GetTime
    | GotTime Posix


init : () -> ( (), Cmd msg )
init _ =
    ( (), Cmd.none )


update : Msg -> () -> ( (), Cmd Msg )
update msg _ =
    case msg of
        GetTime ->
            ( (), Task.perform GotTime Time.now )

        GotTime t ->
            ( (), sendTimeToMain <| Time.posixToMillis t )


port sendTimeToMain : Int -> Cmd msg
