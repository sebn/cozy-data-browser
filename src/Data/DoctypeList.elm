module Data.DoctypeList exposing
    ( DoctypeList
    , findByName
    , first
    , init
    , toList
    , total
    , updateTotal
    )

import AssocList as Dict exposing (Dict)
import Data.Doctype as Doctype exposing (Doctype)
import Data.Pagination as Pagination
import List.Nonempty as Nonempty exposing (Nonempty(..))


type DoctypeList
    = DoctypeList
        { doctypes : Nonempty Doctype
        , expanded : Bool
        , totals : Dict Doctype Pagination.Total
        }


init : Doctype -> List Doctype -> DoctypeList
init firstDoctype otherDoctypes =
    DoctypeList
        { doctypes = Nonempty firstDoctype otherDoctypes
        , expanded = False
        , totals = Dict.empty
        }


first : DoctypeList -> Doctype
first (DoctypeList { doctypes }) =
    Nonempty.head doctypes


findByName : String -> DoctypeList -> Maybe Doctype
findByName doctypeName (DoctypeList { doctypes }) =
    doctypes
        |> Nonempty.toList
        |> Doctype.findByName doctypeName


total : Doctype -> DoctypeList -> Maybe Pagination.Total
total doctype (DoctypeList { totals }) =
    Dict.get doctype totals


updateTotal : Doctype -> Pagination.Total -> DoctypeList -> DoctypeList
updateTotal doctype newTotal (DoctypeList doctypes) =
    DoctypeList { doctypes | totals = Dict.insert doctype newTotal doctypes.totals }


toList : DoctypeList -> List Doctype
toList (DoctypeList { doctypes }) =
    Nonempty.toList doctypes
