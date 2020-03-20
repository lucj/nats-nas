##############################################
#   Creation of client JWT and creds files   #
##############################################

# Folders containing configurations and secrets for the specified domain
CURRENT_DIR="$(dirname $0)"
SECRETS_DIR="${CURRENT_DIR}/secrets"

# Use nats-box to populate volumes with application's admin Account and User (APP, APPU)
docker container run \
  --name box \
  --net host \
  -v $PWD/bin:/nas \
  -v nats_accounts:/nsc/accounts \
  -v nats_nkeys:/nsc/nkeys \
  synadia/nats-box /nas/create-admin.sh

# Get admin user creds file
echo "Copying APPU credentials in [${SECRET_DIR}/APPU.creds]"
docker cp box:/nsc/nkeys/creds/OP/APP/APPU.creds ${SECRETS_DIR}/APPU.creds
docker container rm box
