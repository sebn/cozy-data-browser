module Data.Doc exposing
    ( Doc
    , decoder
    , id
    , keys
    , keysFromList
    , toObject
    , value
    )

import Data.Object as Object exposing (Object)
import Json.Decode as Json
import Set exposing (Set)


type Doc
    = Doc Object


id : Doc -> String
id (Doc object) =
    case Object.value (Object.keyFromString "_id") object of
        Object.ValueString string ->
            string

        _ ->
            ""


toObject : Doc -> Object
toObject (Doc object) =
    object


keys : Doc -> List Object.Key
keys (Doc object) =
    Object.keys object


value : Object.Key -> Doc -> Object.Value
value key (Doc object) =
    Object.value key object


decoder : Json.Decoder Doc
decoder =
    Json.map Doc Object.decoder


keysFromList : List Doc -> List Object.Key
keysFromList docs =
    let
        mergeKeyNames : Doc -> Set String -> Set String
        mergeKeyNames (Doc object) knownKeyNames =
            Object.keys object
                |> List.map Object.keyName
                |> Set.fromList
                |> Set.union knownKeyNames
    in
    docs
        |> List.foldl mergeKeyNames Set.empty
        |> Set.toList
        |> List.map Object.keyFromString
