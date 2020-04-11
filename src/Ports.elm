port module Ports exposing
    ( onLocationHashChange
    , reloadPage
    , setLocationHash
    )


port onLocationHashChange : (String -> msg) -> Sub msg


port setLocationHash : String -> Cmd msg


port reloadPage : () -> Cmd msg
