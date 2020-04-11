module View.Layout exposing
    ( Config
    , ModalConfig
    , layoutDefaults
    , view
    )

import Cozy.Ui as Ui
import Html exposing (Html, div, header, main_, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick, stopPropagationOn)
import Icons
import Json.Decode as Json



-- LAYOUT


type alias Config msg =
    { attributes : List (Html.Attribute msg)
    , nav : List (Html msg)
    , main : List (Html msg)
    , modal : Maybe (ModalConfig msg)
    }


view : Config msg -> Html msg
view config =
    wrapper config
        [ navWrapper config.nav
        , mainWrapper config.main
        , config.modal
            |> Maybe.map viewModalOverlay
            |> Maybe.withDefault (text "")
        ]


layoutDefaults : Config msg
layoutDefaults =
    { attributes = []
    , nav = []
    , main = []
    , modal = Nothing
    }


wrapper : Config msg -> List (Html msg) -> Html msg
wrapper config =
    div <|
        List.concat
            [ [ Ui.flexColumn
              , Ui.flexGrow True
              , Ui.overflowHidden
              , class "u-mt-3-m"
              ]
            , config.attributes
            ]


navWrapper : List (Html msg) -> Html msg
navWrapper =
    Html.nav
        [ Ui.backgroundColor Ui.paleGrey
        , Ui.flexRow
        , Ui.flexShrink False
        , Ui.paddingVertical0
        , Ui.paddingHorizontal1
        , Ui.flexItemsCenter
        , style "height" "3rem"
        , style "box-shadow" "inset 0 -1px 0 0 var(--silver)"
        ]


mainWrapper : List (Html msg) -> Html msg
mainWrapper =
    main_
        [ Ui.flexRow
        , Ui.flexGrow True
        , Ui.overflowScroll
        ]



-- MODAL


type alias ModalConfig msg =
    { title : Html msg
    , contents : List (Html msg)
    , onClose : msg
    , noOp : msg
    }


viewModalOverlay : ModalConfig msg -> Html msg
viewModalOverlay modalConfig =
    div
        [ Ui.positionAbsolute
        , Ui.top0
        , Ui.left0
        , Ui.width100
        , Ui.height100
        , Ui.flexRow
        , Ui.backgroundOverlay
        , Ui.zIndexOverlay
        , onClick modalConfig.onClose
        ]
        [ viewModal modalConfig
        , div [ Ui.flexAuto ] []
        ]


viewModal : ModalConfig msg -> Html msg
viewModal modalConfig =
    div
        [ Ui.flexGrow False
        , Ui.flexColumn
        , Ui.width100
        , Ui.borderRadius4
        , Ui.backgroundColor Ui.white
        , style "margin" "3em"
        , stopPropagationOn "click"
            (Json.succeed ( modalConfig.noOp, True ))
        ]
        [ header [ Ui.flexRow ]
            [ div [ Ui.flexGrow True, Ui.paddingVertical1, Ui.paddingHorizontal2 ]
                [ modalConfig.title
                ]
            , Ui.buttonSecondarySubtle
                [ Ui.margin0
                , Ui.padding1
                , onClick modalConfig.onClose
                ]
                [ Icons.cross ]
            ]
        , div [ Ui.flexGrow True, Ui.overflowAuto ]
            [ div [ Ui.paddingVertical1, Ui.paddingHorizontal2 ] <|
                modalConfig.contents
            ]
        ]
