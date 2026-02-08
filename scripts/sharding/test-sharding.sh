#!/bin/bash
set -e

echo "=== Sharding Tests ==="
echo ""

echo "[1] Config Servers (RSCFG)"
docker exec cfg1 mongosh --quiet --eval '
  rs.status().members.forEach(m => print("  " + m.name + " -> " + m.stateStr));
'

echo ""
echo "[2] Shards status"
for shard in shard1-1 shard2-1 shard3-1; do
  RS=$(docker exec $shard mongosh --quiet --eval 'rs.status().set')
  PRIMARY=$(docker exec $shard mongosh --quiet --eval 'rs.status().members.find(m => m.state === 1).name')
  echo "  $RS: PRIMARY = $PRIMARY"
done

echo ""
echo "[3] Cluster shards"
docker exec mongos mongosh --quiet --eval '
  db.adminCommand({listShards: 1}).shards.forEach(s => print("  " + s._id + ": " + s.host));
'

echo ""
echo "[4] Sharded collections"
docker exec mongos mongosh --quiet --eval '
  var dbs = db.getSiblingDB("config").databases.find({partitioned: true}).toArray();
  dbs.forEach(d => print("  " + d._id + " (sharding enabled)"));
  var colls = db.getSiblingDB("config").collections.find({}).toArray();
  colls.forEach(c => print("    " + c._id + " -> " + JSON.stringify(c.key)));
'

echo ""
echo "[5] Distribution test.test_collection"
docker exec mongos mongosh --quiet --eval '
  var dist = db.getSiblingDB("test").test_collection.aggregate([
    {$collStats: {storageStats: {}}}
  ]).toArray();
  print("  Total docs: " + db.getSiblingDB("test").test_collection.countDocuments());
'
docker exec mongos mongosh --quiet --eval '
  db.getSiblingDB("test").test_collection.getShardDistribution();
'

echo ""
echo "[6] Distribution MovieLens.movies"
docker exec mongos mongosh --quiet --eval '
  print("  Total docs: " + db.getSiblingDB("MovieLens").movies.countDocuments());
'
docker exec mongos mongosh --quiet --eval '
  db.getSiblingDB("MovieLens").movies.getShardDistribution();
'

echo ""
echo "[7] Balancer"
RUNNING=$(docker exec mongos mongosh --quiet --eval 'sh.isBalancerRunning()')
STATE=$(docker exec mongos mongosh --quiet --eval 'sh.getBalancerState()')
echo "  Running: $RUNNING"
echo "  State: $STATE"

echo ""
echo "=== Done ==="
