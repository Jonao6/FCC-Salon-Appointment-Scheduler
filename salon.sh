#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon. How can I help you?"

MAIN_MENU() {
  if [[ $1 ]]
   then
    echo -e "\n$1"
  fi

  SERVICES_OPTIONS=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo -e "$SERVICES_OPTIONS" | while read SERVICE_ID BAR NAME
   do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  if ! [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
   then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICES_AVAILABLE=$($PSQL "SELECT service_id, name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    if [[ -z $SERVICES_AVAILABLE ]]
     then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      if [[ -z $CUSTOMER_NAME ]]
       then
        echo -e "\nI don't have a record for that phone number. What's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
        SERVICE_NAME_FORMATTED=$(echo "$SERVICE_NAME" | sed -E 's/\s//g')
        CUSTOMER_NAME_FORMATTED=$(echo "$CUSTOMER_NAME" | sed -E 's/\s//g')
        echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
        read SERVICE_TIME
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        INSERT_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED atr $SERVICE_TIME, $COSTUMER_NAME_FORMATTED."
      else
        CUSTOMER_NAME_FORMATTED=$(echo "$CUSTOMER_NAME" | sed -E 's/\s//g')
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        SERVICE_NAME_FORMATTED=$(echo "$SERVICE_NAME" | sed -E 's/\s//g')
        echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
        read SERVICE_TIME
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        INSERT_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
      fi
    fi
  fi
}

MAIN_MENU
