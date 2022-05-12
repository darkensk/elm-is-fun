module Main exposing (Model, Msg, main)

import Array exposing (Array)
import Browser
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events



--- MODEL ---


type alias Model =
    { solution : String
    , currentAttempt : Array Char
    , numOfAttempts : Int
    , state : Array (Array Tile)
    , won : Bool
    }


init : () -> ( Model, Cmd msg )
init _ =
    ( { solution = "DUNAJ"
      , currentAttempt = Array.initialize 5 (always ' ')
      , numOfAttempts = 0
      , state = Array.initialize 6 (always (Array.initialize 5 (always Empty)))
      , won = False
      }
    , Cmd.none
    )


type Msg
    = TypeChar Int Char
    | CheckWord


type Tile
    = Empty
    | Incorrect Char
    | Present Char
    | Correct Char



--- VIEW ---


viewTile : Int -> Tile -> Html Msg
viewTile position tile =
    case tile of
        Empty ->
            let
                strToChar : String -> Char
                strToChar =
                    String.toList
                        >> List.head
                        >> Maybe.withDefault ' '
            in
            Html.input
                [ Events.onInput (TypeChar position << strToChar << String.toUpper)
                , Attrs.class "w-8 uppercase text-center outline-none border border-gray-400"
                ]
                []

        Incorrect char ->
            Html.div [ Attrs.class "w-8 border border-gray-400 text-center text-white bg-slate-600" ]
                [ Html.text <| String.fromChar char ]

        Correct char ->
            Html.div [ Attrs.class "w-8 border border-gray-400 text-center text-white bg-green-600" ]
                [ Html.text <| String.fromChar char ]

        Present char ->
            Html.div [ Attrs.class "w-8 border border-gray-400 text-center text-white bg-yellow-500" ]
                [ Html.text <| String.fromChar char ]


view : Model -> Html Msg
view { state, numOfAttempts, won } =
    if numOfAttempts > 5 then
        Html.div [ Attrs.class "h-full grid place-items-center" ] [ Html.text "Sorry, you lost! 😭" ]

    else
        Html.div [ Attrs.class "h-full grid place-items-center" ]
            [ Html.div [ Attrs.class "w-50 grid grid-cols-5 gap-1" ]
                (state
                    |> Array.toList
                    |> List.concatMap (Array.indexedMap viewTile >> Array.toList)
                )
            , if won then
                Html.button
                    [ Attrs.class "rounded bg-slate-400 p-2 text-white"]
                    [ Html.text "CONGRATS! 🎉 SHARE IT WITH THE WORLD!" ]

              else
                Html.button
                    [ Attrs.class "rounded bg-slate-400 p-2 text-white"
                    , Events.onClick CheckWord
                    ]
                    [ Html.text "ENTER" ]
            ]



--- UPDATE ---


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        TypeChar position char ->
            ( { model | currentAttempt = Array.set position char model.currentAttempt }, Cmd.none )

        CheckWord ->
            let
                solutionArray : Array Char
                solutionArray =
                    model.solution
                        |> String.toList
                        |> Array.fromList

                newState =
                    model.currentAttempt
                        |> Array.indexedMap
                            (\index char ->
                                if Just char == Array.get index solutionArray then
                                    Correct char

                                else if String.contains (String.fromChar char) model.solution then
                                    Present char

                                else
                                    Incorrect char
                            )
            in
            ( { model
                | state = Array.set model.numOfAttempts newState model.state
                , numOfAttempts = model.numOfAttempts + 1
                , won = solutionArray == model.currentAttempt
              }
            , Cmd.none
            )



--- MAIN ---


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }
