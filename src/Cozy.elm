module Cozy exposing
    ( Config
    , Error(..)
    , PaginatedDocs
    , getDocs
    , getDoctypes
    , refreshToken
    )

import Data.Doc as Doc exposing (Doc)
import Data.Doctype as Doctype exposing (Doctype)
import Data.Pagination as Pagination exposing (Pagination)
import Http
import Json.Decode as Json
import Regex exposing (Regex)
import Url.Builder


type alias Config =
    { domain : String
    , token : String
    }


getDoctypes : (Result Error (List Doctype) -> msg) -> Config -> Cmd msg
getDoctypes toMsg cozy =
    getData
        { cozy = cozy
        , dataRelativePath = [ "_all_doctypes" ]
        , queryParameters = []
        , decoder = Json.list Doctype.decoder
        , toMsg = toMsg
        }


type alias PaginatedDocs =
    { docs : List Doc
    , doctype : Doctype
    , pagination : Pagination
    }


getDocs : (Result Error PaginatedDocs -> msg) -> Config -> Doctype -> Pagination.Query -> Cmd msg
getDocs toMsg cozy doctype paginationQuery =
    getData
        { cozy = cozy
        , dataRelativePath = [ Doctype.name doctype, "_normal_docs" ]
        , queryParameters = Pagination.queryParameters paginationQuery
        , decoder =
            Json.map3 PaginatedDocs
                (Json.field "rows" (Json.list Doc.decoder))
                (Json.succeed doctype)
                (Json.field "total_rows" (Pagination.decoder paginationQuery))
        , toMsg = toMsg
        }


getData :
    { cozy : Config
    , dataRelativePath : List String
    , queryParameters : List Url.Builder.QueryParameter
    , decoder : Json.Decoder data
    , toMsg : Result Error data -> msg
    }
    -> Cmd msg
getData { cozy, dataRelativePath, decoder, queryParameters, toMsg } =
    -- Use riskyRequest so cozysessid Cookie is included in the headers
    Http.riskyRequest
        { method = "GET"
        , headers =
            [ Http.header "Accept" "application/json"
            , Http.header "Authorization" ("Bearer " ++ cozy.token)
            ]
        , url =
            Url.Builder.crossOrigin
                ("//" ++ cozy.domain)
                ("data" :: dataRelativePath)
                queryParameters
        , body = Http.emptyBody
        , expect = expectJson toMsg decoder
        , timeout = Nothing
        , tracker = Nothing
        }


type Error
    = Unreachable Http.Error
    | UnauthorizedDataAccess Http.Error
    | TokenExpired String
    | UnexpectedError Http.Error


expectJson : (Result Error a -> msg) -> Json.Decoder a -> Http.Expect msg
expectJson toMsg decoder =
    Http.expectStringResponse toMsg
        (responseString >> Result.andThen (decodeJson decoder))


decodeJson : Json.Decoder a -> String -> Result Error a
decodeJson decoder body =
    case Json.decodeString decoder body of
        Ok value ->
            Ok value

        Err err ->
            Err (UnexpectedError (Http.BadBody (Json.errorToString err)))


responseString : Http.Response String -> Result Error String
responseString response =
    case response of
        Http.BadUrl_ url ->
            Err (UnexpectedError (Http.BadUrl url))

        Http.Timeout_ ->
            Err (Unreachable Http.Timeout)

        Http.NetworkError_ ->
            Err (Unreachable Http.NetworkError)

        Http.BadStatus_ { statusCode } body ->
            Err
                (if body |> String.contains "Expired token" then
                    TokenExpired body

                 else if statusCode == 403 then
                    UnauthorizedDataAccess (Http.BadStatus statusCode)

                 else
                    UnexpectedError (Http.BadStatus statusCode)
                )

        Http.GoodStatus_ _ body ->
            Ok body



-- REFRESH TOKEN (dead code for now)


refreshToken : (Result Error String -> msg) -> Cmd msg
refreshToken toMsg =
    Http.riskyRequest
        { method = "GET"
        , headers = []
        , url = "/"
        , body = Http.emptyBody
        , expect =
            Http.expectStringResponse toMsg
                (responseString >> Result.andThen tokenFromHtml)
        , timeout = Nothing
        , tracker = Nothing
        }


tokenFromHtml : String -> Result Error String
tokenFromHtml html =
    let
        submatches =
            html
                |> Regex.findAtMost 1 tokenRegex
                |> List.head
                |> Maybe.andThen (Just << .submatches)
    in
    case submatches of
        Just ((Just submatch) :: _) ->
            Ok submatch

        _ ->
            Http.BadBody "Could not fetch token from application HTML page"
                |> UnexpectedError
                |> Err


tokenRegex : Regex
tokenRegex =
    Regex.fromString "data-cozy-token=\"([^\"]+)\""
        |> Maybe.withDefault Regex.never
