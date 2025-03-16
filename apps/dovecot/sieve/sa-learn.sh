#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 --spam|--ham"
  exit 1
fi

# Assign arguments to variables
option=$1

# Get the user executing the script
user=$USER
server=$SPAMC_HOST

# Run sa-learn with the appropriate option
case $option in
  --spam)
    spamc -c --learntype=spam -u "$user" -d "$server"
    ;;
  --ham)
    spamc -c --learntype=ham -u "$user" -d "$server"
    ;;
  *)
    echo "Invalid option: $option"
    echo "Usage: $0 --spam|--ham"
    exit 1
    ;;
esac

echo "spamc sa-learn completed with option $option by user $user to server $server"
