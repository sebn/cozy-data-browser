module Page.UnexpectedError exposing (view)

import Cozy.Ui as Ui
import Html exposing (Html, a, h4, p, pre, text)
import Html.Attributes exposing (href)
import Http
import View.ErrorDialog as ErrorDialog


view : Http.Error -> Html msg
view httpError =
    ErrorDialog.view "Something went wrong"
        [ p []
            [ text "I have no clue how to fix it. "
            , text "This is probably a bug… (unless your Cozy is broken?)"
            ]
        , p []
            [ text "Sorry for the inconvenience 😿"
            ]
        , h4 [ Ui.title4 ]
            [ text "Reporting the issue" ]
        , p []
            [ text "Please describe your issue "
            , a [ href "https://github.com/sebn/cozy-data-browser/issues/new" ]
                [ text "here" ]
            , text ", explain what you were doing, what happened, including the following information: "
            ]
        , pre []
            [ text (httpErrorMessage httpError)
            ]
        ]


httpErrorMessage : Http.Error -> String
httpErrorMessage httpError =
    case httpError of
        Http.BadUrl url ->
            "Bad URL: " ++ url

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "Network error"

        Http.BadStatus status ->
            "Bad status: " ++ String.fromInt status

        Http.BadBody detail ->
            "Bad body: " ++ detail
