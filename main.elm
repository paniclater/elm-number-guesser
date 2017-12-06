module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { targetNumber : Int
    , currentGuessNumber : String
    , previousGuesses : List Guess
    , range : ( Int, Int )
    }


type alias Guess =
    { guessNumber : Int
    , guessResult : GuessResult
    }


type GuessResult
    = High
    | Low
    | Correct
    | Error


initModel =
    Model 0 "" [] ( 0, 50 )


init : ( Model, Cmd Msg )
init =
    ( initModel
    , Random.generate GotTargetNumber (Random.int 0 50)
    )



-- UPDATE


type Msg
    = GotTargetNumber Int
    | SetCurrentGuessNumber String
    | SetRange String
    | Reset


getGuessResult : Int -> Int -> GuessResult
getGuessResult guess target =
    if guess > target then
        High
    else if guess < target then
        Low
    else
        Correct


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotTargetNumber int ->
            ( { model | targetNumber = int }, Cmd.none )

        SetCurrentGuessNumber label ->
            let
                guessNumberResult =
                    String.toInt model.currentGuessNumber

                guess =
                    case guessNumberResult of
                        Ok int ->
                            Guess int (getGuessResult int model.targetNumber)

                        _ ->
                            Guess 0 Error
            in
                case label of
                    "guess" ->
                        ( { model
                            | currentGuessNumber = ""
                            , previousGuesses = guess :: model.previousGuesses
                          }
                        , Cmd.none
                        )

                    "clear" ->
                        ( { model | currentGuessNumber = "" }, Cmd.none )

                    _ ->
                        ( { model | currentGuessNumber = model.currentGuessNumber ++ label }, Cmd.none )

        SetRange string ->
            let
                seperated =
                    List.map String.toInt (String.words string)
            in
                case seperated of
                    [ Ok min, Ok max ] ->
                        ( { initModel | range = ( min, max ) }, Random.generate GotTargetNumber (Random.int min max) )

                    _ ->
                        ( model, Cmd.none )

        Reset ->
            init



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


calculatorButton currentGuessNumber label =
    let
        isDisabled =
            (label == "-" && currentGuessNumber /= "") || (label == "guess" && currentGuessNumber == "")
    in
        div
            [ class "column button-container" ]
            [ button
                [ class "button calculator-button", disabled isDisabled, onClick (SetCurrentGuessNumber label) ]
                [ text label ]
            ]


calculatorRow buttons currentGuessNumber =
    div [ class "row calculator-row" ] (List.map (calculatorButton currentGuessNumber) buttons)


calculator model =
    div [ class "calculator-container container" ]
        [ div [ class "row calculator-row" ]
            [ div [ class "input-container" ]
                [ h1 [] [ text model.currentGuessNumber ] ]
            ]
        , (calculatorRow [ "1", "2", "3" ] model.currentGuessNumber)
        , (calculatorRow [ "4", "5", "6" ] model.currentGuessNumber)
        , (calculatorRow [ "7", "8", "9" ] model.currentGuessNumber)
        , (calculatorRow [ "clear", "0", "-" ] model.currentGuessNumber)
        , (calculatorRow [ "guess" ] model.currentGuessNumber)
        ]


endGameMessage message =
    (div [] [ h1 [] [ text message ], button [ class "button", onClick Reset ] [ text "Guess Again?" ] ])


guessRow guess =
    tr [] [ td [] [ text (toString guess.guessNumber) ], td [] [ text (toString guess.guessResult) ] ]


view : Model -> Html Msg
view model =
    let
        ( min, max ) =
            model.range

        guessedCorrectly =
            List.length (List.filter (\a -> a.guessResult == Correct) model.previousGuesses) > 0

        outOfGuesses =
            (List.length model.previousGuesses) >= 10
    in
        div [ class "container" ]
            [ div
                [ class "row" ]
                [ h1 [] [ text ("Guess a number between " ++ (toString min) ++ " and " ++ (toString max)) ] ]
            , div [ class "row" ]
                [ h3 [] [ text "Change Number Range?" ] ]
            , div [ class "row" ]
                [ select [ class "range-select", onInput SetRange ]
                    [ option [ value "0 50" ] [ text "Between 0 and 50" ]
                    , option [ value "0 250" ] [ text "Between 0 and 250" ]
                    , option [ value "-500 500" ] [ text "Between -500 and 500" ]
                    ]
                ]
            , if outOfGuesses then
                endGameMessage ("You are out of guesses :(, the number was " ++ toString (model.targetNumber))
              else if guessedCorrectly then
                endGameMessage "You win!"
              else
                (calculator model)
            , table []
                [ thead []
                    [ tr []
                        [ th []
                            [ text "Guess Number" ]
                        , th
                            []
                            [ text "Guess Result" ]
                        ]
                    ]
                , tbody []
                    (List.map guessRow model.previousGuesses)
                ]
            ]
