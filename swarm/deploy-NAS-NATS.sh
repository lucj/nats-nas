# Folders containing configurations and secrets for the specified domain
CURRENT_DIR="$(dirname $0)"
CONF_DIR="${CURRENT_DIR}/conf"
JWT_DIR="${CURRENT_DIR}/jwt"
SECRETS_DIR="${CURRENT_DIR}/secrets"
MANIFESTS_DIR="${CURRENT_DIR}/manifests"

# Create volumes to manage accounts (JWT) and nkeys (creds)
docker volume create nats_accounts
docker volume create nats_nkeys

# Use nats-box to populate volumes with Operator, System Account and System User
docker container run \
  --name box \
  -v $PWD/bin:/nas \
  -v nats_accounts:/nsc/accounts \
  -v nats_nkeys:/nsc/nkeys \
  synadia/nats-box /nas/create-operator.sh

# Get operator jwt
docker cp box:/nsc/accounts/nats/OP/OP.jwt ${JWT_DIR}/OP.jwt

# Get system account jwt
docker cp box:/nsc/accounts/nats/OP/accounts/SYS/SYS.jwt ${JWT_DIR}/SYS.jwt

# Get system user creds file
docker cp box:/nsc/nkeys/creds/OP/SYS/SYSU.creds ${SECRETS_DIR}/SYSU.creds

# Cleanup
docker container rm box

# Running NATS Account Server
docker stack deploy -c ${MANIFESTS_DIR}/nas.yml app

# Generate nats.conf from template
SYSTEM_ACCOUNT_PUBLIC_KEY=$(docker container run --rm -v nats_accounts:/nsc/accounts -v $PWD/bin:/nas -ti --entrypoint /bin/sh synadia/nats-box /nas/get-sys-id.sh)
sed "s/SYSTEM_ACCOUNT_PUBLIC_KEY/$SYSTEM_ACCOUNT_PUBLIC_KEY/g" ${CONF_DIR}/nats.conf.tpl > ${CONF_DIR}/nats.conf

# Running NATS Server
docker stack deploy -c ${MANIFESTS_DIR}/nats.yml app
