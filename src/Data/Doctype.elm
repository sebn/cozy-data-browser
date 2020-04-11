module Data.Doctype exposing
    ( Doctype
    , decoder
    , findByName
    , name
    , sort
    )

import Json.Decode as Json


type Doctype
    = Doctype String


decoder : Json.Decoder Doctype
decoder =
    Json.map Doctype Json.string


name : Doctype -> String
name (Doctype name_) =
    name_


sort : List Doctype -> List Doctype
sort =
    List.sortWith compare


compare : Doctype -> Doctype -> Basics.Order
compare (Doctype doctypeName1) (Doctype doctypeName2) =
    Basics.compare doctypeName1 doctypeName2


findByName : String -> List Doctype -> Maybe Doctype
findByName searchedName doctypes =
    doctypes
        |> List.filter (name >> (==) searchedName)
        |> List.head
