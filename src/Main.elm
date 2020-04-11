module Main exposing (main)

import Browser
import Cozy
import Data.Doctype as Doctype exposing (Doctype)
import Data.DoctypeList as DoctypeList
import Data.Pagination as Pagination
import Html exposing (Html, text)
import Page.DataBrowser as DataBrowser
import Ports
import Route exposing (Route(..))
import View.Layout as Layout exposing (layoutDefaults)
import View.Spinner as Spinner



-- MAIN


main : Program Flags LoadingModel Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Flags =
    { cozy : Cozy.Config
    , locationHash : String
    }



-- MODEL


type LoadingModel
    = Loading Flags
    | Loaded Page
    | NoDoctypes (Maybe Cozy.Error)


type Page
    = DataBrowser DataBrowser.Model
    | PageNotFound


init : Flags -> ( LoadingModel, Cmd Msg )
init flags =
    ( Loading flags
    , Cozy.getDoctypes LoadedDoctypes flags.cozy
    )



-- UPDATE


type Msg
    = LoadedDoctypes (Result Cozy.Error (List Doctype))
    | LocationHashChanged String
    | DataBrowserMsg DataBrowser.Msg


update : Msg -> LoadingModel -> ( LoadingModel, Cmd Msg )
update msg loading =
    case ( loading, msg ) of
        ( Loading flags, LocationHashChanged locationHash ) ->
            ( Loading { flags | locationHash = locationHash }, Cmd.none )

        ( Loading flags, LoadedDoctypes (Ok (firstDoctype :: otherDoctypes)) ) ->
            let
                model =
                    DataBrowser.init flags.cozy
                        (DoctypeList.init firstDoctype otherDoctypes)
            in
            updateRoute flags.locationHash model

        ( Loading _, LoadedDoctypes (Ok []) ) ->
            ( NoDoctypes Nothing, Cmd.none )

        ( Loading _, LoadedDoctypes (Err error) ) ->
            ( NoDoctypes (Just error), Cmd.none )

        ( Loaded (DataBrowser model), LocationHashChanged locationHash ) ->
            updateRoute locationHash model

        ( Loaded (DataBrowser model), DataBrowserMsg subMsg ) ->
            DataBrowser.update subMsg model
                |> Tuple.mapBoth (DataBrowser >> Loaded) (Cmd.map DataBrowserMsg)

        _ ->
            ( loading, Cmd.none )


updateRoute : String -> DataBrowser.Model -> ( LoadingModel, Cmd Msg )
updateRoute locationHash model =
    case Route.fromLocationHash locationHash of
        Just Route.Home ->
            let
                firstDoctypeName =
                    model.doctypes
                        |> DoctypeList.first
                        |> Doctype.name
            in
            ( Loaded (DataBrowser model)
            , Route.redirect (Route.Docs firstDoctypeName Pagination.offsetStart)
            )

        Just (Route.Docs doctypeName offset) ->
            case DataBrowser.findDoctype doctypeName model of
                Nothing ->
                    ( Loaded PageNotFound, Cmd.none )

                Just doctype ->
                    DataBrowser.loadDocs doctype offset model
                        |> Tuple.mapBoth (DataBrowser >> Loaded) (Cmd.map DataBrowserMsg)

        Nothing ->
            ( Loaded PageNotFound, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : LoadingModel -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.onLocationHashChange LocationHashChanged
        ]



-- VIEW


view : LoadingModel -> Html Msg
view loading =
    case loading of
        Loading _ ->
            Layout.view { layoutDefaults | nav = [ Spinner.view True ] }

        Loaded (DataBrowser model) ->
            DataBrowser.view model
                |> Html.map DataBrowserMsg

        Loaded PageNotFound ->
            Layout.view { layoutDefaults | main = [ text "Not found" ] }

        NoDoctypes error ->
            let
                errorMessage =
                    error
                        |> Maybe.andThen (always (Just "Error while loading doctypes"))
                        |> Maybe.withDefault "No doctypes"
            in
            Layout.view { layoutDefaults | main = [ text errorMessage ] }
