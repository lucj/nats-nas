#!/bin/bash

# This script is called to add application Admin Acount and User (APP, APPU)

nsc add account -n APP
nsc add user --account APP --name APPU --allow-pub ">" --allow-sub ">"
nsc push -a APP
