module Cozy.Ui exposing
    ( SelectConfig
    , backgroundColor
    , backgroundOverlay
    , borderCollapse
    , borderColor
    , borderRadius3
    , borderRadius4
    , borderSolid
    , borderWidth0
    , borderWidthHalf
    , buttonLinkSmall
    , buttonSecondarySubtle
    , buttonSmall
    , charcoalGrey
    , coolGrey
    , cursorPointer
    , displayBlock
    , ellipsisEnd
    , ellipsisMiddle
    , flexAuto
    , flexColumn
    , flexGrow
    , flexItemsCenter
    , flexRow
    , flexShrink
    , fontSizeLarge
    , height100
    , isActive
    , left0
    , margin0
    , margin1
    , marginHorizontal1
    , marginHorizontalHalf
    , marginLeftHalf
    , marginRightHalf
    , marginVertical0
    , marginVerticalHalf
    , maxWidth2
    , maxWidth4
    , maxWidth5
    , minWidth1
    , minWidth100
    , minWidth5
    , nav
    , navItem
    , navLink
    , navText
    , overflowAuto
    , overflowHidden
    , overflowScroll
    , padding0
    , padding1
    , paddingHalf
    , paddingHorizontal1
    , paddingHorizontal2
    , paddingRight0
    , paddingVertical0
    , paddingVertical1
    , paleGrey
    , positionAbsolute
    , selectBoxTiny
    , silver
    , textAlignLeft
    , textColor
    , title2
    , title4
    , top0
    , white
    , width100
    , width2
    , zIndexOverlay
    , zIndexPopover
    )

import Html exposing (Html, a, button, div, li, span, text, ul)
import Html.Attributes exposing (class, style)
import Html.Events exposing (stopPropagationOn)
import Json.Decode as Json



-- COLORS


type Color
    = Color String


charcoalGrey : Color
charcoalGrey =
    Color "charcoalGrey"


coolGrey : Color
coolGrey =
    Color "coolGrey"


paleGrey : Color
paleGrey =
    Color "paleGrey"


silver : Color
silver =
    Color "silver"


white : Color
white =
    Color "white"



-- Z-INDEX


zIndexPopover : Html.Attribute msg
zIndexPopover =
    style "z-index" "40"


zIndexOverlay : Html.Attribute msg
zIndexOverlay =
    style "z-index" "70"



-- TYPOGRAPHY


title2 : Html.Attribute msg
title2 =
    class "u-title-2"


title4 : Html.Attribute msg
title4 =
    class "u-title-4"



-- BORDER


borderCollapse : Html.Attribute msg
borderCollapse =
    style "border-collapse" "collapse"


borderRadius3 : Html.Attribute msg
borderRadius3 =
    class "u-bdrs-3"


borderRadius4 : Html.Attribute msg
borderRadius4 =
    class "u-bdrs-4"


borderWidth0 : Html.Attribute msg
borderWidth0 =
    class "u-bdw-0"


borderWidthHalf : Html.Attribute msg
borderWidthHalf =
    style "border-width" "1px"


borderSolid : Html.Attribute msg
borderSolid =
    style "border-style" "solid"


borderColor : Color -> Html.Attribute msg
borderColor (Color colorName) =
    style "border-color" <| "var(--" ++ colorName ++ ")"



-- CURSOR


cursorPointer : Html.Attribute msg
cursorPointer =
    class "u-c-pointer"



-- MARGINS


margin0 : Html.Attribute msg
margin0 =
    class "u-m-0"


margin1 : Html.Attribute msg
margin1 =
    class "u-m-1"


marginVertical0 : Html.Attribute msg
marginVertical0 =
    class "u-mv-0"


marginVerticalHalf : Html.Attribute msg
marginVerticalHalf =
    class "u-mv-half"


marginHorizontalHalf : Html.Attribute msg
marginHorizontalHalf =
    class "u-mh-half"


marginHorizontal1 : Html.Attribute msg
marginHorizontal1 =
    class "u-mh-1"


marginLeftHalf : Html.Attribute msg
marginLeftHalf =
    class "u-ml-half"


marginRightHalf : Html.Attribute msg
marginRightHalf =
    class "u-mr-half"



-- PADDINGS


padding0 : Html.Attribute msg
padding0 =
    class "u-p-0"


padding1 : Html.Attribute msg
padding1 =
    class "u-p-1"


paddingHalf : Html.Attribute msg
paddingHalf =
    class "u-p-half"


paddingVertical0 : Html.Attribute msg
paddingVertical0 =
    class "u-pv-0"


paddingVertical1 : Html.Attribute msg
paddingVertical1 =
    class "u-pv-1"


paddingHorizontal1 : Html.Attribute msg
paddingHorizontal1 =
    class "u-ph-1"


paddingHorizontal2 : Html.Attribute msg
paddingHorizontal2 =
    class "u-ph-2"


paddingRight0 : Html.Attribute msg
paddingRight0 =
    class "u-pr-0"



-- TEXT


fontSizeLarge : Html.Attribute msg
fontSizeLarge =
    class "u-fz-large"


textColor : Color -> Html.Attribute msg
textColor (Color colorName) =
    class ("u-" ++ colorName)


textAlignLeft : Html.Attribute msg
textAlignLeft =
    class "u-ta-left"


ellipsisEnd : Html.Attribute msg
ellipsisEnd =
    class "u-ellipsis"


ellipsisMiddle : Html.Attribute msg
ellipsisMiddle =
    class "u-midellipsis"



--DISPLAY


displayBlock : Html.Attribute msg
displayBlock =
    class "u-db"



-- FLEXBOX DISPLAY


flexRow : Html.Attribute msg
flexRow =
    class "u-flex u-flex-row"


flexColumn : Html.Attribute msg
flexColumn =
    class "u-flex u-flex-column"


flexAuto : Html.Attribute msg
flexAuto =
    class "u-flex-auto"


flexItemsCenter : Html.Attribute msg
flexItemsCenter =
    class "u-flex-items-center"


flexGrow : Bool -> Html.Attribute msg
flexGrow condition =
    if condition then
        class "u-flex-grow-1"

    else
        class "u-flex-grow-0"


flexShrink : Bool -> Html.Attribute msg
flexShrink condition =
    if condition then
        class "u-flex-shrink-1"

    else
        class "u-flex-shrink-0"



-- POSITION


positionAbsolute : Html.Attribute msg
positionAbsolute =
    class "u-pos-absolute"


top0 : Html.Attribute msg
top0 =
    class "u-t-0"


left0 : Html.Attribute msg
left0 =
    class "u-l-0"



-- WIDTH / HEIGHT


width2 : Html.Attribute msg
width2 =
    class "u-w-2"


width100 : Html.Attribute msg
width100 =
    class "u-w-100"


minWidth1 : Html.Attribute msg
minWidth1 =
    class "u-miw-1"


minWidth5 : Html.Attribute msg
minWidth5 =
    class "u-miw-5"


minWidth100 : Html.Attribute msg
minWidth100 =
    class "u-miw-100"


maxWidth2 : Html.Attribute msg
maxWidth2 =
    class "u-maw-2"


maxWidth4 : Html.Attribute msg
maxWidth4 =
    class "u-maw-4"


maxWidth5 : Html.Attribute msg
maxWidth5 =
    class "u-maw-5"


height100 : Html.Attribute msg
height100 =
    class "u-h-100"



-- BACKGROUND COLOR


backgroundColor : Color -> Html.Attribute msg
backgroundColor (Color colorName) =
    class ("u-bg-" ++ colorName)


backgroundOverlay : Html.Attribute msg
backgroundOverlay =
    class "u-bg-overlay"



-- OVERFLOW


overflowAuto : Html.Attribute msg
overflowAuto =
    class "u-ov-auto"


overflowScroll : Html.Attribute msg
overflowScroll =
    class "u-ov-scroll"


overflowHidden : Html.Attribute msg
overflowHidden =
    class "u-ov-hidden"



-- COMPONENTS


buttonSmall : List (Html.Attribute msg) -> List (Html msg) -> Html msg
buttonSmall attributes =
    button (class "c-btn c-btn--small" :: attributes)


buttonLinkSmall : List (Html.Attribute msg) -> List (Html msg) -> Html msg
buttonLinkSmall attributes =
    a (class "c-btn c-btn--small" :: attributes)


buttonSecondarySubtle : List (Html.Attribute msg) -> List (Html msg) -> Html msg
buttonSecondarySubtle attributes =
    button (class "c-btn c-btn--secondary c-btn--subtle" :: attributes)


type alias SelectConfig option msg =
    { placeholder : String
    , options : List option
    , selected : Maybe option
    , label : option -> String
    , optionAttributes : option -> List (Html.Attribute msg)
    , actions : option -> List (Html msg)
    , menuIsOpen : Bool
    , onOpenMenu : msg
    , onCloseMenu : msg
    }


selectBoxTiny : SelectConfig option msg -> Html msg
selectBoxTiny config =
    div []
        [ selectButtonTiny config
        , if config.menuIsOpen then
            selectMenu config

          else
            text ""
        ]


selectButtonTiny : SelectConfig option msg -> Html msg
selectButtonTiny config =
    button
        [ class "c-select c-select--tiny"
        , textAlignLeft
        , stopPropagationOn "click" <|
            Json.succeed
                ( if config.menuIsOpen then
                    config.onCloseMenu

                  else
                    config.onOpenMenu
                , True
                )
        ]
        [ text <|
            case config.selected of
                Just value ->
                    config.label value

                Nothing ->
                    config.placeholder
        ]


selectMenu : SelectConfig option msg -> Html msg
selectMenu config =
    div
        [ displayBlock
        , positionAbsolute
        , minWidth5
        , style "max-height" "calc(100vh - 8rem)"
        , zIndexPopover
        , textColor charcoalGrey
        , backgroundColor white
        , borderWidth0
        , borderRadius3
        , style "box-shadow" "0 0.063rem 0.188rem 0 rgba(50,54,63,0.19), 0 0.375rem 1.125rem 0 rgba(50,54,63,0.19)"
        , overflowHidden
        , style "overflow-y" "scroll"
        ]
        [ config.options
            |> List.map (selectOption config)
            |> nav []
        ]


selectOption : SelectConfig option msg -> option -> Html msg
selectOption config option =
    navItem []
        [ navLink
            (config.optionAttributes option
                |> (::) (isActive (config.selected == Just option))
                |> (::) paddingRight0
            )
            [ navText []
                (config.actions option
                    |> (::) (text " ")
                    |> (::) (text (config.label option))
                )
            ]
        ]


nav : List (Html.Attribute msg) -> List (Html msg) -> Html msg
nav attributes =
    ul (class "c-nav" :: attributes)


navItem : List (Html.Attribute msg) -> List (Html msg) -> Html msg
navItem attributes =
    li (class "c-nav-item" :: attributes)


navLink : List (Html.Attribute msg) -> List (Html msg) -> Html msg
navLink attributes =
    a (class "c-nav-link" :: attributes)


isActive : Bool -> Html.Attribute msg
isActive condition =
    class <|
        if condition then
            "is-active"

        else
            ""


navText : List (Html.Attribute msg) -> List (Html msg) -> Html msg
navText attributes =
    span (class "c-nav-text" :: attributes)
