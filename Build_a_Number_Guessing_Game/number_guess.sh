#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( 1 + RANDOM % 1000 ))

echo "Enter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'") # check if the user has already played before
#if the user is new they are registered
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_NEW_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
# greeting old users
else
  USER=$($PSQL "SELECT username FROM users WHERE user_id = $USER_ID")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE user_id = $USER_ID")
  echo "Welcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# let's play!
echo "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=1
while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  if [[ ! $GUESS =~ [0-9]+ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    fi
  fi
  NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
  read GUESS
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# update the database: add users (if they're new), compare number of guesses and best games, and update the number of games played
USER_ID_GAME=$($PSQL "SELECT user_id FROM games WHERE user_id = $USER_ID")
if [[ -z $USER_ID_GAME ]]
then
  INSERT_USER=$($PSQL "INSERT INTO games (user_id, games_played, best_game) VALUES ($USER_ID, 1, $NUMBER_OF_GUESSES)")
else
  BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE user_id = $USER_ID_GAME")
  if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE games SET best_game = $NUMBER_OF_GUESSES WHERE user_id = $USER_ID_GAME")
  fi
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE games SET games_played = games_played + 1 WHERE user_id = $USER_ID_GAME")
fi
