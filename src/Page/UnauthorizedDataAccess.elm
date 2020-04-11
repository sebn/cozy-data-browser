module Page.UnauthorizedDataAccess exposing (view)

import Html exposing (Html, a, p, text)
import Html.Attributes exposing (href)
import View.ErrorDialog as ErrorDialog


view : Html msg
view =
    ErrorDialog.view "Unauthorized data access"
        [ p []
            [ text "I donʼt have access to those data. "
            , text "Right now there is no easy way to get access to all your data at once. "
            , text "I have to know of every type of data in advance."
            ]
        , p []
            [ text "In case youʼve some technical background, "
            , text "you can help me by looking on GitHub whether "
            , a [ href "https://github.com/sebn/cozy-data-browser/labels/doctype" ]
                [ text "somebody already requested it"
                ]
            , text ", or ask for this type of data "
            , a [ href "https://github.com/sebn/cozy-data-browser/issues/new" ]
                [ text "to be supported"
                ]
            , text "."
            ]
        ]
