#!/bin/sh
set -o errexit -o nounset
command -v shellcheck >/dev/null && shellcheck "$0"

PASSWORD=${PASSWORD:-1234567890}
CHAIN_ID=${CHAIN_ID:-wasm-testing}
MONIKER=${MONIKER:-wasm-moniker}

STAKE=${STAKE_TOKEN:-ustake}
FEE=${FEE_TOKEN:-ucosm}
TRANSFER_PORT=${TRANSFER_PORT:-transfer}

# both types of tokens
START_BALANCE="1000000000$STAKE,1000000000$FEE"

echo "Creating genesis ..."
rm -rf "${HOME}/.wasmd"
wasmd init --chain-id "$CHAIN_ID" "$MONIKER"
cd "${HOME}/.wasmd"

sed -i "s/\"stake\"/\"$STAKE\"/" config/genesis.json # staking/governance token is hardcoded in config, change this
sed -i "s/\"port_id\": *\"transfer\"/\"port_id\": \"$TRANSFER_PORT\"/" config/genesis.json # allow custom ibc transfer port

# this is essential for sub-1s block times (or header times go crazy)
sed -i 's/"time_iota_ms": "1000"/"time_iota_ms": "10"/' config/genesis.json

echo "Setting up validator ..."
if ! wasmd keys show validator 2>/dev/null; then
  echo "Validator does not yet exist. Creating it ..."
  (
    echo "$PASSWORD"
    echo "$PASSWORD"
  ) | wasmd keys add validator
fi
# hardcode the validator account for this instance
echo "$PASSWORD" | wasmd add-genesis-account validator "$START_BALANCE"

echo "Setting up accounts ..."
# (optionally) add a few more genesis accounts
for addr in "$@"; do
  echo "$addr"
  wasmd add-genesis-account "$addr" "$START_BALANCE"
done

echo "Creating genesis tx ..."
SELF_DELEGATION="3000000$STAKE" # 3 ATOM (leads to a voting power of 3)
(
  echo "$PASSWORD"
  echo "$PASSWORD"
  echo "$PASSWORD"
) | wasmd gentx validator "$SELF_DELEGATION" --offline --chain-id "$CHAIN_ID" --moniker="$MONIKER"
wasmd collect-gentxs

# so weird, but found I needed the -M flag after lots of debugging odd error messages
# happening when redirecting stdout
jq -S -M . < config/genesis.json > genesis.tmp
mv genesis.tmp config/genesis.json
chmod a+rx config/genesis.json

# Custom settings in config.toml
sed -i"" \
  -e 's/^cors_allowed_origins =.*$/cors_allowed_origins = ["*"]/' \
  -e 's/^timeout_propose =.*$/timeout_propose = "100ms"/' \
  -e 's/^timeout_propose_delta =.*$/timeout_propose_delta = "100ms"/' \
  -e 's/^timeout_prevote =.*$/timeout_prevote = "100ms"/' \
  -e 's/^timeout_prevote_delta =.*$/timeout_prevote_delta = "100ms"/' \
  -e 's/^timeout_precommit =.*$/timeout_precommit = "100ms"/' \
  -e 's/^timeout_precommit_delta =.*$/timeout_precommit_delta = "100ms"/' \
  -e 's/^timeout_commit =.*$/timeout_commit = "200ms"/' \
  "config/config.toml"

# Custom settings app.toml
sed -i"" \
  -e 's/^enable =.*$/enable = true/' \
  -e 's/^enabled-unsafe-cors =.*$/enabled-unsafe-cors = true/' \
  -e 's/^minimum-gas-prices = \".*\"/minimum-gas-prices = \"0.025ucosm\"/' \
  "config/app.toml"