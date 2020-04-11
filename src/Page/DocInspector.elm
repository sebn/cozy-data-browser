module Page.DocInspector exposing (view)

import Cozy.Ui as Ui
import Data.Doc as Doc exposing (Doc)
import Data.Object as Object exposing (Object)
import Html exposing (Html, br, div, li, span, strong, text, ul)


view : Doc -> Html msg
view doc =
    doc
        |> Doc.toObject
        |> viewObject
        |> div
            [ Ui.height100
            , Ui.overflowAuto
            ]


viewObject : Object -> List (Html msg)
viewObject object =
    Object.keys object |> List.map (viewProperty object)


viewProperty : Object -> Object.Key -> Html msg
viewProperty object key =
    div [ Ui.marginVerticalHalf ]
        [ viewKey key
        , viewValue key (Object.value key object)
        ]


viewKey : Object.Key -> Html msg
viewKey key =
    strong [ Ui.marginRightHalf ]
        [ text (Object.keyName key ++ ":") ]


viewValue : Object.Key -> Object.Value -> Html msg
viewValue key value =
    case value of
        Object.ValueArray [] ->
            text ""

        Object.ValueArray list ->
            viewArray list

        Object.ValueObject object ->
            object |> viewObject |> div [ Ui.marginVertical0, Ui.marginHorizontal1 ]

        Object.ValueBool True ->
            viewScalar [ text "true" ]

        Object.ValueBool False ->
            viewScalar [ text "false" ]

        Object.ValueNumber float ->
            viewScalar [ text (String.fromFloat float) ]

        Object.ValueString string ->
            viewScalar <|
                case Object.keyName key of
                    "password" ->
                        [ text "∙∙∙∙∙∙∙∙" ]

                    _ ->
                        string
                            |> String.split "\n"
                            |> List.map text
                            |> List.intersperse (br [] [])

        Object.ValueNull ->
            text ""


viewScalar : List (Html msg) -> Html msg
viewScalar =
    span []


viewArray : List Object.Value -> Html msg
viewArray list =
    list
        |> List.map viewArrayItem
        |> ul
            [ Ui.padding0
            , Ui.margin0
            , Ui.marginHorizontalHalf
            ]


viewArrayItem : Object.Value -> Html msg
viewArrayItem value =
    li [ Ui.marginVerticalHalf ]
        [ viewValue Object.keyNone value
        ]
