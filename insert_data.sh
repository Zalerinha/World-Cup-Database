#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
#clean tables everytime that this script runs 
echo $($PSQL "TRUNCATE games, teams")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART")
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART")
#read the games.csv file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
if [[ $YEAR != "year" ]]
  then
#get team_winner_id
  TEAM_WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")       
#if ID not found
  if [[ -z $TEAM_WINNER_ID ]]   
    then
    #insert team  
    INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
    if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
      echo inserted into teams, $WINNER
    fi
    #get new team ID
    TEAM_WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")  
  fi

  #get team_opponent_id
  TEAM_OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  #if ID not found
  if [[ -z $TEAM_OPPONENT_ID ]]
    then
  #insert team
    INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")   
    if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
    then
    echo inserte into team, $OPPONENT
    fi
    #get new ID
    TEAM_OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  fi

  #insert games
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES 
  ($YEAR, '$ROUND', $TEAM_WINNER_ID, $TEAM_OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
    echo Inserted into games, $YEAR $ROUND $TEAM_WINNER_ID $TEAM_OPPONENT_ID $WINNER_GOALS $OPPONENT_GOALS
  fi
fi
done



