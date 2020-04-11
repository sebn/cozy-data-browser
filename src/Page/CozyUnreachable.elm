module Page.CozyUnreachable exposing (view)

import Html exposing (Html, text)
import View.ErrorDialog as ErrorDialog


view : Html msg
view =
    ErrorDialog.view "Cozy Unreachable"
        [ text "I could not contact your Cozy… Are you connected to the Internet? \u{1F914}"
        ]
