module Data.Object exposing
    ( Key
    , Object
    , Value(..)
    , decoder
    , keyFromString
    , keyName
    , keyNone
    , keys
    , value
    )

import AssocList as Dict exposing (Dict)
import Dict as ElmDict
import Json.Decode as Json


type Object
    = Object (Dict Key Value)


keyFromString : String -> Key
keyFromString =
    Key


keys : Object -> List Key
keys (Object dict) =
    Dict.keys dict |> List.sortBy keyName


value : Key -> Object -> Value
value key (Object dict) =
    Dict.get key dict |> Maybe.withDefault ValueNull


decoder : Json.Decoder Object
decoder =
    dictDecoder Key valueDecoder
        |> Json.map Object


dictDecoder : (String -> a) -> Json.Decoder b -> Json.Decoder (Dict a b)
dictDecoder stringToKey valueDecoder_ =
    Json.dict valueDecoder_ |> Json.map (ElmDict.toList >> List.map (Tuple.mapFirst stringToKey) >> Dict.fromList)



-- KEY


type Key
    = Key String


keyName : Key -> String
keyName (Key name) =
    name


keyNone : Key
keyNone =
    Key ""



-- VALUE


type Value
    = ValueArray (List Value)
    | ValueObject Object
    | ValueBool Bool
    | ValueNumber Float
    | ValueString String
    | ValueNull


valueDecoder : Json.Decoder Value
valueDecoder =
    Json.oneOf
        [ Json.map ValueArray <| Json.list <| Json.lazy (\_ -> valueDecoder)
        , Json.map ValueObject <| Json.lazy (\_ -> decoder)
        , Json.map ValueBool <| Json.bool
        , Json.map ValueNumber <| Json.float
        , Json.map ValueString <| Json.string
        , Json.null ValueNull
        ]
