#!/bin/bash

##############################################
#   Creation of client JWT and creds files   #
##############################################

NAME=$1
SUBJECT=$2

# Add a client dedicated export to the APP (application administration) account
nsc add export --account APP --name ${NAME}_export --subject $SUBJECT --private

# Create an account
nsc add account --name $NAME
NAME_ACCOUNT_ID=$(nsc describe account $NAME | grep 'Account ID' | awk '{print $5}')

# Create a user
nsc add user --account $NAME --name $NAME --deny-pub ">" --allow-sub $SUBJECT

# Securing the import
rm -f /tmp/${NAME}-activation.jwt 2>/dev/null
nsc generate activation -o /tmp/${NAME}-activation.jwt --account APP --target-account $NAME_ACCOUNT_ID --subject $SUBJECT

# Add an import to the account
nsc add import --account $NAME --name ${NAME}_export --token /tmp/${NAME}-activation.jwt

# Accounts details
nsc describe account $NAME
nsc describe account APP

# Push to the account server
nsc push -A
