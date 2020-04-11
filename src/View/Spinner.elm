module View.Spinner exposing (view)

import Cozy.Ui as Ui
import Html exposing (Html, span, text)
import Html.Attributes exposing (style)
import Svg exposing (svg)
import Svg.Attributes exposing (d, opacity, viewBox)


view : Bool -> Html msg
view spinning =
    if spinning then
        span
            [ Ui.paddingHorizontal1
            , style "vertical-align" "bottom"
            ]
            [ svg
                [ viewBox "0 0 32 32"
                , Svg.Attributes.width "24"
                , Svg.Attributes.height "24"
                , style "fill" "var(--primaryColor)"
                , style "animation" "spin 1s linear infinite"
                ]
                [ Svg.path
                    [ opacity ".25"
                    , d "M16 0a16 16 0 0 0 0 32 16 16 0 0 0 0-32m0 4a12 12 0 0 1 0 24 12 12 0 0 1 0-24"
                    ]
                    []
                , Svg.path [ d "M16 0a16 16 0 0 1 16 16h-4a12 12 0 0 0-12-12z" ] []
                ]
            ]

    else
        text ""
