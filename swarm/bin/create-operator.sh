#!/bin/bash

# This script is called in the NATS Account Server + NATS Server setup
# Several public tokens + user creds are generated:
# - Main Operator
# - System account + user

# Main operator
nsc add operator -n OP

# Update operator so `nsc push` can be used to send new or updated accounts to the Nats Account Server
nsc edit operator -u http://172.17.0.1:9090/jwt/v1

# System account + user
nsc add account -n SYS
nsc add user -n SYSU
