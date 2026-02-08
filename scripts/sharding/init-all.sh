#!/bin/bash
set -e

echo "=== Init Sharding Cluster ==="
echo ""

wait_ready() {
  echo -n "  $1..."
  for i in {1..30}; do
    docker exec $1 mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1 && echo " OK" && return 0
    sleep 1
  done
  echo " FAIL" && return 1
}

echo "[0] Containers"
for c in cfg1 cfg2 cfg3 shard1-1 shard2-1 shard3-1; do
  wait_ready $c
done

echo ""
echo "[1] Config Servers"
docker exec -i cfg1 mongosh --quiet < scripts/sharding/init-config-servers.js
echo "  Waiting 10s for RSCFG..."
sleep 10

echo ""
echo "[2] Shards"
docker exec -i shard1-1 mongosh --quiet < scripts/sharding/init-shard1.js
docker exec -i shard2-1 mongosh --quiet < scripts/sharding/init-shard2.js
docker exec -i shard3-1 mongosh --quiet < scripts/sharding/init-shard3.js
echo "  Waiting 10s for shards..."
sleep 10

echo ""
echo "[3] Mongos"
echo "  Waiting for mongos to connect to config servers..."
sleep 15
docker exec mongos mongosh --quiet --eval 'print("  mongos... OK")'

echo ""
echo "[4] Cluster"
docker exec -i mongos mongosh --quiet < scripts/sharding/init-cluster.js

echo ""
echo "=== Cluster ready (port 31000) ==="
echo ""
echo "Next steps:"
echo "  docker exec mongos mongoimport --db MovieLens --collection movies --file /data/import/movielens_movies.json"
echo "  docker exec -i mongos mongosh < scripts/sharding/insert-data.js"
