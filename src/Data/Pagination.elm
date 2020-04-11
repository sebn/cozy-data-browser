module Data.Pagination exposing
    ( Limit
    , Offset
    , Pagination
    , Query
    , Total
    , decoder
    , defaultLimit
    , from
    , limitFromString
    , limitQueryParameter
    , limitToInt
    , limitToString
    , nextOffset
    , offset
    , offsetStart
    , offsetToInt
    , offsetToString
    , previousOffset
    , queryParameters
    , summary
    , total
    , totalToString
    , urlOffsetParser
    )

import Json.Decode as Json
import Url.Builder
import Url.Parser as UrlP



-- PAGINATION QUERY


type alias Query =
    { skip : Int
    , limit : Limit
    }


queryParameters : Query -> List Url.Builder.QueryParameter
queryParameters { skip, limit } =
    [ Url.Builder.int "skip" skip
    , limitQueryParameter limit
    ]



-- PAGINATION


type Pagination
    = Pagination
        { offset : Offset
        , limit : Limit
        , total : Total
        }


from : Offset -> Limit -> Total -> Pagination
from offset_ limit total_ =
    Pagination { offset = offset_, limit = limit, total = total_ }


decoder : Query -> Json.Decoder Pagination
decoder query =
    Json.map3 from
        (Json.succeed (Offset query.skip))
        (Json.succeed query.limit)
        (Json.map Total Json.int)


offset : Pagination -> Offset
offset (Pagination pagination) =
    pagination.offset


total : Pagination -> Total
total (Pagination pagination) =
    pagination.total


previousOffset : Pagination -> Maybe Offset
previousOffset (Pagination pagination) =
    let
        (Offset offset_) =
            pagination.offset
    in
    if offset_ > 0 then
        Just (offsetPrevious defaultLimit offset_)

    else
        Nothing


nextOffset : Pagination -> Maybe Offset
nextOffset (Pagination pagination) =
    let
        (Offset offset_) =
            pagination.offset

        (Limit limit) =
            pagination.limit

        (Total total_) =
            pagination.total

        nextOffsetValue =
            offset_ + limit
    in
    if nextOffsetValue < total_ then
        Just (Offset nextOffsetValue)

    else
        Nothing


summary : Pagination -> String
summary (Pagination pagination) =
    let
        (Offset offset_) =
            pagination.offset

        (Limit limit) =
            pagination.limit

        (Total total_) =
            pagination.total

        start : Int
        start =
            offset_ + 1

        end : Int
        end =
            Basics.min
                (offset_ + limit)
                total_

        range : String
        range =
            if start == end then
                String.fromInt end

            else
                String.fromInt start ++ " - " ++ String.fromInt end
    in
    range ++ " of " ++ String.fromInt total_



-- OFFSET


type Offset
    = Offset Int


offsetToString : Offset -> String
offsetToString =
    String.fromInt << offsetToInt


offsetToInt : Offset -> Int
offsetToInt (Offset int) =
    int


offsetStart : Offset
offsetStart =
    Offset 0


offsetPrevious : Limit -> Int -> Offset
offsetPrevious limit offset_ =
    Offset (Basics.max 0 (offset_ - limitToInt limit))


urlOffsetParser : UrlP.Parser (Offset -> a) a
urlOffsetParser =
    UrlP.custom "OFFSET" <|
        \segment ->
            String.toInt segment |> Maybe.andThen offsetFromInt


offsetFromInt : Int -> Maybe Offset
offsetFromInt value =
    if value >= 0 then
        Just (Offset value)

    else
        Nothing



-- LIMIT


type Limit
    = Limit Int


limitFromString : String -> Limit
limitFromString string =
    String.toInt string
        |> Maybe.andThen limitFromInt
        |> Maybe.withDefault defaultLimit


limitFromInt : Int -> Maybe Limit
limitFromInt int =
    if int > 0 then
        Just (Limit int)

    else
        Nothing


limitQueryParameter : Limit -> Url.Builder.QueryParameter
limitQueryParameter (Limit int) =
    Url.Builder.int "limit" int


limitToInt : Limit -> Int
limitToInt (Limit int) =
    int


limitToString : Limit -> String
limitToString =
    limitToInt >> String.fromInt


defaultLimit : Limit
defaultLimit =
    Limit 25



-- TOTAL


type Total
    = Total Int


totalToString : Total -> String
totalToString (Total total_) =
    String.fromInt total_
