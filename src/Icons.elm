module Icons exposing
    ( cross
    , pathSeparator
    )

import Html exposing (Html)
import Html.Attributes exposing (style)
import Svg exposing (svg)
import Svg.Attributes exposing (d, fillRule, transform, viewBox)


cross : Html msg
cross =
    svg
        [ viewBox "0 0 24 24"
        , Svg.Attributes.width "24"
        , Svg.Attributes.height "24"
        , style "fill" "var(--coolGrey)"
        ]
        [ Svg.path
            [ fillRule "evenodd"
            , d "M106.585786,44 L96.2928932,33.7071068 C95.9023689,33.3165825 95.9023689,32.6834175 96.2928932,32.2928932 C96.6834175,31.9023689 97.3165825,31.9023689 97.7071068,32.2928932 L108,42.5857864 L118.292893,32.2928932 C118.683418,31.9023689 119.316582,31.9023689 119.707107,32.2928932 C120.097631,32.6834175 120.097631,33.3165825 119.707107,33.7071068 L109.414214,44 L119.707107,54.2928932 C120.097631,54.6834175 120.097631,55.3165825 119.707107,55.7071068 C119.316582,56.0976311 118.683418,56.0976311 118.292893,55.7071068 L108,45.4142136 L97.7071068,55.7071068 C97.3165825,56.0976311 96.6834175,56.0976311 96.2928932,55.7071068 C95.9023689,55.3165825 95.9023689,54.6834175 96.2928932,54.2928932 L106.585786,44 Z"
            , transform "translate(-96 -32)"
            ]
            []
        ]


pathSeparator : Html msg
pathSeparator =
    svg
        [ viewBox "0 0 16 16"
        , Svg.Attributes.width "16"
        , Svg.Attributes.height "16"
        , style "fill" "var(--coolGrey)"
        , style "margin" "0 4px"
        ]
        [ Svg.path
            [ fillRule "evenodd"
            , d "M12.707,7.2929 L6.707,1.2929 C6.316,0.9019 5.684,0.9019 5.293,1.2929 C4.902,1.6839 4.902,2.3159 5.293,2.7069 L10.586,7.9999 L5.293,13.2929 C4.902,13.6839 4.902,14.3159 5.293,14.7069 C5.684,15.0979 6.316,15.0979 6.707,14.7069 L12.707,8.7069 C13.098,8.3159 13.098,7.6839 12.707,7.2929"
            ]
            []
        ]
