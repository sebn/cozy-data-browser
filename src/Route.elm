module Route exposing
    ( Route(..)
    , fromLocationHash
    , redirect
    , toLocationHash
    )

import Data.Pagination as Pagination
import Ports
import Url exposing (Url)
import Url.Builder as UrlB
import Url.Parser as UrlP exposing ((</>), Parser)


type Route
    = Home
    | Docs String Pagination.Offset


parser : Parser (Route -> a) a
parser =
    UrlP.oneOf
        [ UrlP.map Home UrlP.top
        , UrlP.map Docs (UrlP.string </> Pagination.urlOffsetParser)
        ]


fromLocationHash : String -> Maybe Route
fromLocationHash locationHash =
    let
        fragment =
            String.dropLeft 1 locationHash
    in
    fromFragment fragment


fromFragment : String -> Maybe Route
fromFragment fragment =
    fragment
        |> fakeUrlFromPath
        |> UrlP.parse parser


fakeUrlFromPath : String -> Url
fakeUrlFromPath path =
    { protocol = Url.Http
    , host = ""
    , port_ = Nothing
    , path = path
    , query = Nothing
    , fragment = Nothing
    }


toLocationHash : Route -> String
toLocationHash route =
    "#" ++ toFragment route


toFragment : Route -> String
toFragment route =
    case route of
        Home ->
            ""

        Docs doctypeName offset ->
            UrlB.absolute [ doctypeName, Pagination.offsetToString offset ] []


redirect : Route -> Cmd msg
redirect route =
    route |> toLocationHash |> Ports.setLocationHash
