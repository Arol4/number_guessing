#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Enter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ $USER_ID ]]
then
  GAMES_PLAYED_INFO=$($PSQL "SELECT COUNT(game_played_id),MIN(guesses) FROM games_played WHERE user_id=$USER_ID")
  echo $GAMES_PLAYED_INFO | while read GAMES_PLAYED BAR BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
fi
echo "Guess the secret number between 1 and 1000:"
read USER_NUMBER
GUESSES=1
while [[ $USER_NUMBER != $SECRET_NUMBER ]]
do
  if [[ ! $USER_NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $USER_NUMBER > $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi
  GUESSES=$(( GUESSES + 1 ))
  read USER_NUMBER
done
echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
INSERT_GAME_PLAYED_RESULT=$($PSQL "INSERT INTO games_played(guesses,secret_number,user_id) VALUES($GUESSES,$SECRET_NUMBER,$USER_ID)")

