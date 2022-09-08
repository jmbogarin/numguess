#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

R_NUM=$(( ( RANDOM % 1000 )  + 1 ))

echo "Enter your username:"
read USERNAME

QUERY=$($PSQL "SELECT * FROM games WHERE username='$USERNAME'")

if [[ -z $QUERY ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  ADD_PLAYER_RESULT=$($PSQL "INSERT INTO games(username) VALUES('$USERNAME')")
  arrDATA=($USERNAME 0 9999)
else
  arrDATA=(${QUERY//|/})
  echo "Welcome back, ${arrDATA[0]}! You have played ${arrDATA[1]} games, and your best game took ${arrDATA[2]} guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS
ATTEMPTS=1

while true
do
    if ! [[ $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    elif [[ $GUESS -gt $R_NUM ]]
    then
      echo "It's lower than that, guess again:"
      ATTEMPTS=$((ATTEMPTS+1))
    elif [[ $GUESS -lt $R_NUM ]]
    then
      echo "It's higher than that, guess again:"
      ATTEMPTS=$((ATTEMPTS+1))
    else
      echo "You guessed it in $ATTEMPTS tries. The secret number was $GUESS. Nice job!"
      # add one to games played
      ADD_GAME_RESULT=$($PSQL "UPDATE games SET games_played = (${arrDATA[1]} + 1) WHERE username = '${arrDATA[0]}'")
      # replace best game if necessary
      if [[ $ATTEMPTS -lt ${arrDATA[2]} ]]
      then
        BEST_GAME_RESULT=$($PSQL "UPDATE games SET best_game = $ATTEMPTS WHERE username = '${arrDATA[0]}'")
      fi
      exit
    fi
    read GUESS
done

