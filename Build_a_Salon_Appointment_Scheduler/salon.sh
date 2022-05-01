#!/bin/bash

PSQL="psql -X -U freecodecamp -d salon --no-align --tuples-only -c"

echo -e "\n~~~ WELCOME TO THE VOGUE SALON! ~~~\n"
echo -e "Here are our beauty treatments, how would you like to treat yourself?\n"

VOGUE_MENU() {
  if [[ $1 ]]
  then
    echo -e "$1"
  fi
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | sed -r 's/\|/) /' 
  
  TAKE_APPOINTMENT
}

TAKE_APPOINTMENT() {
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ [0-9] || $SERVICE_ID_SELECTED -gt 5 ]]
  then
    VOGUE_MENU "\nPlease enter a valid selection!\n"
  else
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    echo -e "\nPlease enter your phone number"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nYou are a new customer, we are very glad to serve you! Please enter your name"
      read CUSTOMER_NAME
      NEW_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi
    echo -e "\nWhat time would you like to book your $SERVICE?"
    read SERVICE_TIME
    if [[ $SERVICE_TIME =~ am ]]
    then
      SERVICE_TIME=$(echo $SERVICE_TIME | sed -r 's/am//g')
      if [[ ! $SERVICE_TIME =~ :[0-9]+$ ]]
      then
        SERVICE_TIME=$(echo SERVICE_TIME | sed -r 's/$/:00$/g')
      fi
    elif [[ $SERVICE_TIME =~ pm ]]
    then
      SERVICE_TIME=$(echo $SERVICE_TIME | sed -r '/s/pm//g')
      (( SERVICE_TIME += 12 ))
      SERVICE_TIME=$(echo $SERVICE_TIME | sed 's/$/:00/g')
    fi
    RESERVATION=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

VOGUE_MENU
