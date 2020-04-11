module Data.DocSelection exposing
    ( DocSelection
    , fromList
    , select
    , toList
    , unselect
    )

import Data.Doc exposing (Doc)


type alias DocSelection =
    { before : List Doc
    , selected : Maybe Doc
    , after : List Doc
    }


select : Doc -> DocSelection -> DocSelection
select expectedDoc oldSelection =
    let
        selectExpectedDoc : Doc -> DocSelection -> DocSelection
        selectExpectedDoc doc newSelection =
            if doc == expectedDoc then
                { newSelection | selected = Just expectedDoc }

            else
                newSelection.selected
                    |> Maybe.andThen (Just << always { newSelection | after = doc :: newSelection.after })
                    |> Maybe.withDefault { newSelection | before = doc :: newSelection.before }
    in
    oldSelection
        |> toList
        |> List.foldl selectExpectedDoc (fromList [])


unselect : DocSelection -> DocSelection
unselect =
    toList >> fromList


fromList : List Doc -> DocSelection
fromList list =
    { before = List.reverse list
    , selected = Nothing
    , after = []
    }


toList : DocSelection -> List Doc
toList docs =
    List.concat
        [ docs.before
            |> List.reverse
        , docs.selected
            |> Maybe.andThen (Just << List.singleton)
            |> Maybe.withDefault []
        , docs.after
        ]
