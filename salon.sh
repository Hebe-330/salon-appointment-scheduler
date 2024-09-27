#! /bin/bash

# Define the PSQL variable
PSQL="psql --username=freecodecamp --dbname=salon -t -c"

# Function to display services
display_services() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo "Welcome to My Salon, how can I help you?"
  # echo "$SERVICES" | while read SERVICE
  # do
  #   SERVICE_ID=$(echo $SERVICE | cut -d '|' -f 1)
  #   SERVICE_NAME=$(echo $SERVICE | cut -d '|' -f 2 | sed 's/^ *//g')
  #   echo "$SERVICE_ID) $SERVICE_NAME"
  # done

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"

  done
}

# Function to prompt for service selection
prompt_for_service() {
  echo -e "\nPlease enter the service number you would like:"
  read SERVICE_ID_SELECTED

  # Check if the selected service exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed 's/^ *//g')

  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
    display_services
    prompt_for_service
  else
    echo -e "\nYou have selected: $SERVICE_NAME"
  fi
}

# Function to prompt for customer details
prompt_for_customer_details() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # Check if the customer exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed 's/^ *//g')

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # Insert new customer into the customers table
    INSERT_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # Insert the appointment into the appointments table
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ((SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'), $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    echo -e "\nThere was an error scheduling your appointment. Please try again."
  fi
}

# Display services and prompt for selection
display_services
prompt_for_service
prompt_for_customer_details
