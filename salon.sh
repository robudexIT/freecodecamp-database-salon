#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  if [[ ! -z $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICE_LIST=$($PSQL "SELECT * FROM services")
  echo "$SERVICE_LIST " | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

 #Choose service
 CHOOSE_SERVICE
}
CHOOSE_SERVICE(){
  # Select Serivice
   read SERVICE_ID_SELECTED
  #If service is not a number
  #  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] 
  #  then
   # send to main menu
  #  MAIN_MENU "Your choose is invalid" 
  #  fi
   SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  #IF service is not in the choices
  if [[ -z $SERVICE_NAME ]]
  then
  # send to main menu
  MAIN_MENU "I could not find that service. What would you like today?"
  else
    #ask for customer phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    #get customer info (eg name)
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #if customer not found
    if [[ -z $CUSTOMER_NAME ]]
    then
    # ask for customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    #save customer info in the database
    CUSTOMER_SAVE_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    
    fi
  
  #ask what time customer 
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  #get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  #create appointments
  CREATE_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
   if [[ $CREATE_APPOINTMENTS = "INSERT 0 1" ]] 
   then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
   fi
  fi 
  
}
MAIN_MENU


