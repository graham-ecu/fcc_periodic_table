#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# get the first command line argument
INPUT=$1

# check if an argument was provided
if [ -z "$INPUT" ]
then
  echo Please provide an element as an argument.
else
  # check if input is not numeric
  if [[ ! $INPUT =~ ^[0-9]+$ ]];
  then
    # capitalize the first letter and make any other leters lowercase
    FORMATTED_INPUT=$(echo "$INPUT" | awk '{print toupper(substr($0, 1, 1)) tolower(substr($0, 2))}')
    # get atomic number from the elements table
    ATOMIC_NUMBER_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$FORMATTED_INPUT' OR name='$FORMATTED_INPUT'")
  else
    # if input is numeric check if it exists in the elements table
    ATOMIC_NUMBER_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$INPUT")
  fi

  if [[ -z $ATOMIC_NUMBER_RESULT ]]
  then
    echo I could not find that element in the database.
  else
    # get element info from elements table
    NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER_RESULT")
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER_RESULT")
    # get element info from properties table
    ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER_RESULT")
    MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER_RESULT")
    BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER_RESULT")
    # get element info from types table
    TYPE_ID=$($PSQL "SELECT type_id FROM properties WHERE atomic_number=$ATOMIC_NUMBER_RESULT")
    TYPE=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID")

    # print element info
    echo -e "The element with atomic number $ATOMIC_NUMBER_RESULT is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
fi
