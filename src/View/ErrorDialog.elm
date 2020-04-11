module View.ErrorDialog exposing (view)

import Cozy.Ui as Ui
import Html exposing (Html, div, h2, text)


view : String -> List (Html msg) -> Html msg
view title details =
    div [ Ui.margin1 ]
        [ h2 [ Ui.title2 ] [ text title ]
        , div []
            details
        ]
