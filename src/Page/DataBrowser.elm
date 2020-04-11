module Page.DataBrowser exposing
    ( Model
    , Msg
    , findDoctype
    , init
    , loadDocs
    , update
    , view
    )

import Cozy
import Cozy.Ui as Ui
import Data.Doc as Doc exposing (Doc)
import Data.DocSelection as DocSelection exposing (DocSelection)
import Data.Doctype as Doctype exposing (Doctype)
import Data.DoctypeList as DoctypeList exposing (DoctypeList)
import Data.Object as Object exposing (Object)
import Data.Pagination as Pagination exposing (Pagination)
import Html exposing (Html, div, h2, input, span, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, disabled, href, placeholder, style, title, type_, value)
import Html.Events exposing (onClick, onInput)
import Icons
import Page.CozyUnreachable
import Page.DocInspector as DocInspector
import Page.UnauthorizedDataAccess
import Page.UnexpectedError
import Ports
import Route
import Set exposing (Set)
import View.Layout as Layout
import View.Spinner as Spinner



-- MODEL


type alias Model =
    { contents : Contents
    , cozy : Cozy.Config
    , doctypes : DoctypeList
    , doctypesVisible : Bool
    , offset : Pagination.Offset
    , requestedLimit : String
    , selectedDoctype : Doctype
    }


type Contents
    = ContentsLoading
    | ContentsLoaded DocSelection
    | ContentsLoadingError Cozy.Error


validLimit : Model -> Pagination.Limit
validLimit { requestedLimit } =
    Pagination.limitFromString requestedLimit


selectDoc : Doc -> Model -> Model
selectDoc doc model =
    case model.contents of
        ContentsLoaded docs ->
            { model
                | contents = ContentsLoaded (DocSelection.select doc docs)
            }

        _ ->
            model


unselectDoc : Model -> Model
unselectDoc model =
    case model.contents of
        ContentsLoaded docs ->
            { model
                | contents = ContentsLoaded (DocSelection.unselect docs)
            }

        _ ->
            model


init : Cozy.Config -> DoctypeList -> Model
init cozy doctypes =
    { contents = ContentsLoading
    , cozy = cozy
    , doctypes = doctypes
    , doctypesVisible = False
    , requestedLimit = ""
    , offset = Pagination.offsetStart
    , selectedDoctype = DoctypeList.first doctypes
    }


findDoctype : String -> Model -> Maybe Doctype
findDoctype searchedName { doctypes } =
    DoctypeList.findByName searchedName doctypes


updateTotal : Doctype -> Pagination.Total -> Model -> Model
updateTotal doctype total model =
    { model
        | doctypes = DoctypeList.updateTotal doctype total model.doctypes
    }


currentPagination : Model -> Maybe Pagination
currentPagination model =
    let
        { selectedDoctype, offset } =
            model

        limit =
            validLimit model
    in
    model.doctypes
        |> DoctypeList.total selectedDoctype
        |> Maybe.andThen (Just << Pagination.from offset limit)


isLoading : Model -> Bool
isLoading { contents } =
    case contents of
        ContentsLoading ->
            True

        _ ->
            False


loadDocs : Doctype -> Pagination.Offset -> Model -> ( Model, Cmd Msg )
loadDocs doctype offset model =
    ( { model
        | selectedDoctype = doctype
        , offset = offset
        , contents = ContentsLoading
      }
    , Cozy.getDocs LoadedDocs
        model.cozy
        doctype
        { skip = Pagination.offsetToInt offset
        , limit = validLimit model
        }
    )



-- UPDATE


type Msg
    = NoOp
    | ShowAvailableDoctypes
    | HideAvailableDoctypes
    | LoadedDocs (Result Cozy.Error Cozy.PaginatedDocs)
    | ViewDoc Doc
    | HideDoc
    | RequestLimit String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HideAvailableDoctypes ->
            ( { model | doctypesVisible = False }, Cmd.none )

        ShowAvailableDoctypes ->
            ( { model | doctypesVisible = True }, Cmd.none )

        LoadedDocs (Ok { docs, doctype, pagination }) ->
            ( { model
                | contents = ContentsLoaded (DocSelection.fromList docs)
                , selectedDoctype = doctype
                , offset = Pagination.offset pagination
              }
                |> updateTotal doctype (Pagination.total pagination)
            , Cmd.none
            )

        LoadedDocs (Err (Cozy.TokenExpired _)) ->
            ( model, Ports.reloadPage () )

        LoadedDocs (Err cozyError) ->
            ( { model | contents = ContentsLoadingError cozyError }
            , Cmd.none
            )

        ViewDoc doc ->
            ( selectDoc doc model, Cmd.none )

        HideDoc ->
            ( unselectDoc model, Cmd.none )

        RequestLimit requestedLimit ->
            ( { model
                | requestedLimit = requestedLimit
                , contents = ContentsLoading
              }
            , Cozy.getDocs LoadedDocs
                model.cozy
                model.selectedDoctype
                { skip = Pagination.offsetToInt model.offset
                , limit = validLimit model
                }
            )

        _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    Layout.view
        { attributes = [ onClick HideAvailableDoctypes ]
        , nav = viewNavItems model
        , main =
            [ case model.contents of
                ContentsLoading ->
                    text ""

                ContentsLoaded docs ->
                    viewTable (DocSelection.toList docs)

                ContentsLoadingError cozyError ->
                    viewErrorPage cozyError
            ]
        , modal =
            case model.contents of
                ContentsLoaded docs ->
                    docs.selected
                        |> Maybe.map (modalConfig model.selectedDoctype)

                _ ->
                    Nothing
        }


viewErrorPage : Cozy.Error -> Html msg
viewErrorPage cozyError =
    case cozyError of
        Cozy.Unreachable _ ->
            Page.CozyUnreachable.view

        Cozy.UnauthorizedDataAccess _ ->
            Page.UnauthorizedDataAccess.view

        Cozy.TokenExpired _ ->
            text ""

        Cozy.UnexpectedError httpError ->
            Page.UnexpectedError.view httpError


modalConfig : Doctype -> Doc -> Layout.ModalConfig Msg
modalConfig doctype doc =
    { title =
        h2 [ Ui.title2 ]
            [ span [ Ui.textColor Ui.coolGrey ] [ text (Doctype.name doctype) ]
            , Icons.pathSeparator
            , span [] [ text (Doc.id doc) ]
            ]
    , contents = [ DocInspector.view doc ]
    , onClose = HideDoc
    , noOp = NoOp
    }


viewNavItems : Model -> List (Html Msg)
viewNavItems model =
    [ viewDoctypeSelection model
    , div [ Ui.flexRow, Ui.flexItemsCenter ] <|
        case currentPagination model of
            Just pagination ->
                viewPaginationNavItems model.selectedDoctype pagination

            _ ->
                []
    , div [ Ui.flexGrow True ]
        [ Spinner.view (isLoading model)
        ]
    , viewLimit (validLimit model)
    ]


viewDoctypeSelection : Model -> Html Msg
viewDoctypeSelection model =
    div
        [ Ui.minWidth5
        , Ui.marginRightHalf
        ]
        [ Ui.selectBoxTiny
            { placeholder = "Select a doctype..."
            , options = DoctypeList.toList model.doctypes
            , selected = Just model.selectedDoctype
            , label = Doctype.name
            , optionAttributes = doctypeOptionAttributes
            , actions = List.singleton << viewDoctypeTotal model.doctypes
            , menuIsOpen = model.doctypesVisible
            , onOpenMenu = ShowAvailableDoctypes
            , onCloseMenu = HideAvailableDoctypes
            }
        ]


doctypeOptionAttributes : Doctype -> List (Html.Attribute msg)
doctypeOptionAttributes doctype =
    [ href <| Route.toLocationHash <| Route.Docs (Doctype.name doctype) Pagination.offsetStart
    ]


viewDoctypeTotal : DoctypeList -> Doctype -> Html msg
viewDoctypeTotal doctypes doctype =
    text <|
        case DoctypeList.total doctype doctypes of
            Nothing ->
                ""

            Just total ->
                "(" ++ Pagination.totalToString total ++ ")"


viewLimit : Pagination.Limit -> Html Msg
viewLimit limit =
    div [ Ui.marginLeftHalf ]
        [ text "by "
        , input
            [ type_ "number"
            , Ui.width2
            , Html.Attributes.min "1"
            , Html.Attributes.max "1000"
            , placeholder "25"
            , value (Pagination.limitToString limit)
            , onInput RequestLimit
            ]
            []
        ]


viewPaginationNavItems : Doctype -> Pagination -> List (Html Msg)
viewPaginationNavItems doctype pagination =
    [ viewPaginationNavButtonPrevious doctype pagination
    , viewPaginationNavButtonNext doctype pagination
    , text (Pagination.summary pagination)
    ]


viewPaginationNavButtonPrevious : Doctype -> Pagination -> Html Msg
viewPaginationNavButtonPrevious doctype pagination =
    viewPaginationNavButton "<" doctype (Pagination.previousOffset pagination)


viewPaginationNavButtonNext : Doctype -> Pagination -> Html Msg
viewPaginationNavButtonNext doctype pagination =
    viewPaginationNavButton ">" doctype (Pagination.nextOffset pagination)


viewPaginationNavButton : String -> Doctype -> Maybe Pagination.Offset -> Html Msg
viewPaginationNavButton label doctype targetOffset =
    case targetOffset of
        Nothing ->
            viewPaginationNavButtonDisabled label

        Just offset ->
            viewPaginationNavButtonEnabled label doctype offset


viewPaginationNavButtonDisabled : String -> Html msg
viewPaginationNavButtonDisabled label =
    Ui.buttonSmall (disabled True :: paginationButtonAttributes)
        [ text label ]


viewPaginationNavButtonEnabled : String -> Doctype -> Pagination.Offset -> Html msg
viewPaginationNavButtonEnabled label doctype offset =
    let
        doctypeName : String
        doctypeName =
            Doctype.name doctype

        locationHash : String
        locationHash =
            Route.toLocationHash (Route.Docs doctypeName offset)
    in
    Ui.buttonLinkSmall (href locationHash :: paginationButtonAttributes)
        [ text label ]


paginationButtonAttributes : List (Html.Attribute msg)
paginationButtonAttributes =
    [ Ui.fontSizeLarge
    , Ui.minWidth1
    ]


viewTable : List Doc -> Html Msg
viewTable docs =
    let
        keys =
            docs
                |> Doc.keysFromList
                |> List.filter (not << isExcludedKey)
    in
    table
        [ Ui.borderCollapse
        , Ui.minWidth100
        ]
        [ keys
            |> List.map viewTableColumnHeader
            |> thead []
        , docs
            |> List.map (viewTableRow keys)
            |> tbody []
        ]


isExcludedKey : Object.Key -> Bool
isExcludedKey key =
    Set.member (Object.keyName key) excludedKeyNames


excludedKeyNames : Set String
excludedKeyNames =
    Set.fromList
        [ "category"
        , "cozyMetadata"
        , "id"
        , "metadata"
        , "relationships"
        ]


viewTableColumnHeader : Object.Key -> Html msg
viewTableColumnHeader key =
    th (tableCellAttributes key)
        [ text (Object.keyName key) ]


viewTableRow : List Object.Key -> Doc -> Html Msg
viewTableRow keys doc =
    keys
        |> List.map (viewTableCell doc)
        |> tr
            [ Ui.cursorPointer
            , class "hoverPaleGrey"
            , onClick (ViewDoc doc)
            ]


viewTableCell : Doc -> Object.Key -> Html msg
viewTableCell doc key =
    td (tableCellAttributes key)
        [ viewValue key (Doc.value key doc)
        ]


viewValue : Object.Key -> Object.Value -> Html msg
viewValue key value =
    case ( Object.keyName key, value ) of
        ( "checksum", Object.ValueString checksum ) ->
            viewMidEllipsized checksum

        ( "cozyMetadata", _ ) ->
            viewEllipsis

        ( "message", _ ) ->
            viewEllipsis

        ( "password", Object.ValueString _ ) ->
            text "∙∙∙∙∙∙∙∙"

        ( "prefix", _ ) ->
            viewEllipsis

        ( "_rev", Object.ValueString rev ) ->
            viewRev rev

        ( _, Object.ValueArray list ) ->
            viewValueArray list

        ( _, Object.ValueObject object ) ->
            viewValueObject object

        ( _, Object.ValueBool True ) ->
            text "true"

        ( _, Object.ValueBool False ) ->
            text "false"

        ( _, Object.ValueNumber float ) ->
            text <| String.fromFloat float

        ( keyName, Object.ValueString string ) ->
            if String.endsWith "_id" keyName then
                viewMidEllipsized string

            else if String.endsWith "_at" keyName then
                viewDateTime string

            else
                text string

        ( _, Object.ValueNull ) ->
            text ""


viewMidEllipsized : String -> Html msg
viewMidEllipsized id =
    if String.startsWith "io.cozy." id then
        text id

    else
        span [ title id ]
            [ text (String.slice 0 4 id)
            , viewEllipsis
            , text (String.slice -4 (String.length id) id)
            ]


viewRev : String -> Html msg
viewRev rev =
    span []
        [ rev
            |> String.split "-"
            |> List.head
            |> Maybe.withDefault ""
            |> text
        , viewEllipsis
        ]


viewEllipsis : Html msg
viewEllipsis =
    span [ Ui.textColor Ui.coolGrey ] [ text "…" ]


viewDateTime : String -> Html msg
viewDateTime string =
    span [ title string ]
        [ text (String.slice 0 19 string)
        , viewEllipsis
        ]


viewValueObject : Object -> Html msg
viewValueObject object =
    let
        keys : List Object.Key
        keys =
            Object.keys object
    in
    case keys of
        [] ->
            text ""

        key :: otherKeys ->
            span []
                [ viewValue key (Object.value key object)
                , case List.length otherKeys of
                    0 ->
                        text ""

                    _ ->
                        viewEllipsis
                ]


viewValueArray : List Object.Value -> Html msg
viewValueArray list =
    case list of
        [] ->
            text ""

        firstValue :: otherValues ->
            span []
                [ viewValue Object.keyNone firstValue
                , case List.length otherValues of
                    0 ->
                        text ""

                    _ ->
                        viewEllipsis
                ]


tableCellAttributes : Object.Key -> List (Html.Attribute msg)
tableCellAttributes _ =
    [ Ui.borderSolid
    , Ui.borderWidthHalf
    , Ui.borderColor Ui.silver
    , Ui.maxWidth5
    , Ui.paddingHalf
    , Ui.overflowHidden
    , style "white-space" "nowrap"
    ]
