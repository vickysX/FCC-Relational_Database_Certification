#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

# what happens when the user searches for an element that does not exist in the database
OUTPUT_NON_EXISTING () {
  echo "I could not find that element in the database."
}

# search the database for an existing element and display infos about the element
SEARCH_DATABASE() {
  ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $1")
  TYPE=$($PSQL "SELECT type FROM types INNER JOIN properties USING (type_id) WHERE atomic_number = $1")
  MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $1")
  BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $1")
  echo "The element with atomic number $1 is $2 ($3). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
}

# if the user does not provide any argument
if [[ ! $1 ]]
then 
  echo Please provide an element as an argument.
# querying the database 
else
  # if the argument is an atomic number
  if [[ $1 =~ [0-9]+ ]] 
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
    # if that number is not in the database
    if [[ -z $ATOMIC_NUMBER ]]
    then
      OUTPUT_NON_EXISTING
    # continue
    else
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
      NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")

      SEARCH_DATABASE $ATOMIC_NUMBER $NAME $SYMBOL
    fi
  # if the argument is the name of an element
  elif [[ $1 =~ [A-Z][a-z]{2,} ]]
  then
    NAME=$($PSQL "SELECT name FROM elements WHERE name = '$1'")
    # if the name is not in the database
    if [[ -z $NAME ]]
    then
      OUTPUT_NON_EXISTING
    # continue
    else
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$NAME'")
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name = '$NAME'")

      SEARCH_DATABASE $ATOMIC_NUMBER $NAME $SYMBOL
    fi
  # if the argument is a symbol of an element
  elif [[ $1 =~ [A-Z][a-z]? ]]
  then
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol = '$1'")
    # if the symbol is not in the database
    if [[ -z $SYMBOL ]]
    then
      OUTPUT_NON_EXISTING
    # continue
    else
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$SYMBOL'")
      NAME=$($PSQL "SELECT name FROM elements WHERE symbol = '$SYMBOL'")

      SEARCH_DATABASE $ATOMIC_NUMBER $NAME $SYMBOL
    fi
  fi
fi
