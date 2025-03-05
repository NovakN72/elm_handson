port module Worker exposing (..)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Json.Decode exposing (Error(..), Value, decodeValue, string)


port sendData : String -> Cmd msg


port receiveData : (Value -> msg) -> Sub msg


type alias Model =
    { dataFromJS : String
    , jsonError : Maybe Error
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveData ReceivedDataFromJS


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick SendDataToJs ]
            [ text "Send Data to JavaScript" ]
        , viewDataFromJSOrError model
        ]


viewDataFromJSOrError : Model -> Html Msg
viewDataFromJSOrError model =
    case model.jsonError of
        Just error ->
            viewError error

        Nothing ->
            viewDataFromJS model.dataFromJS


viewError : Error -> Html Msg
viewError jsonError =
    let
        errorHeading =
            "Couldn't receive data from JavaScript"

        errorMessage =
            case jsonError of
                Failure message _ ->
                    message

                _ ->
                    "Error: Invalid JSON"
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]


viewDataFromJS : String -> Html msg
viewDataFromJS data =
    div []
        [ br [] []
        , strong [] [ text "Data received from JavaScript: " ]
        , text data
        ]


type Msg
    = SendDataToJs
    | ReceivedDataFromJS Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendDataToJs ->
            ( model, sendData "Hello js" )

        ReceivedDataFromJS data ->
            case decodeValue string data of
                Ok val ->
                    ( { model | dataFromJS = val }, Cmd.none )

                Err error ->
                    ( { model | jsonError = Just error }, Cmd.none )


init : () -> ( Model, Cmd Msg )
init _ =
    ( { dataFromJS = ""
      , jsonError = Nothing
      }
    , Cmd.none
    )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
