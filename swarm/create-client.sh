# Folders containing configurations and secrets for the specified domain
CURRENT_DIR="$(dirname $0)"
SECRETS_DIR="${CURRENT_DIR}/secrets"

usage() {
    echo "usage: ./create_client.sh NAME SUBJECT"
    echo "- NAME: name of the client"
    echo "- SUBJECT: subject the client is authorized to subscribed to"
    exit 1
}

NAME=$1
SUBJECT=$2

if [ -z "$NAME" -o -z "$SUBJECT" ]; then
    echo "NAME and SUBJECT must be specified"
    usage
fi

# Use nats-box to populate volumes with client account and user
docker container run \
  --name box \
  --net host \
  -v $PWD/bin:/nas\
  -v nats_accounts:/nsc/accounts \
  -v nats_nkeys:/nsc/nkeys \
  synadia/nats-box /nas/create-client.sh $NAME $SUBJECT

# Get client's user creds file
echo "Copying user $NAME credentials into [${SECRETS_DIR}/$NAME.creds]"
docker cp box:/nsc/nkeys/creds/OP/$NAME/$NAME.creds ${SECRETS_DIR}/$NAME.creds
docker container rm box
