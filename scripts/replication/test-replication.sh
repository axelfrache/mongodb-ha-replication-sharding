#!/bin/bash
set -e

echo "=== Replication Tests RS1 ==="
echo ""

echo "[1] Cluster status"
docker exec mongo-primary mongosh --quiet --eval '
  rs.status().members.forEach(m => print("  " + m.name + " -> " + m.stateStr));
'

echo ""
echo "[2] Write on PRIMARY"
docker exec mongo-primary mongosh --quiet --eval '
  var result = db.getSiblingDB("MovieLens").users.insertOne({name: "TestReplication", age: 25});
  print("  Document inserted: " + result.insertedId);
'

echo ""
echo "[3] Read on SECONDARY (after 3s)"
sleep 3
for i in 1 2 3; do
  COUNT=$(docker exec mongo-secondary$i mongosh --quiet --eval '
    db.getMongo().setReadPref("secondary");
    db.getSiblingDB("MovieLens").users.countDocuments({name: "TestReplication"});
  ')
  echo "  mongo-secondary$i: $COUNT doc(s)"
done

echo ""
echo "[4] Total count"
for node in mongo-primary mongo-secondary1 mongo-secondary2 mongo-secondary3; do
  COUNT=$(docker exec $node mongosh --quiet --eval '
    db.getMongo().setReadPref("secondaryPreferred");
    db.getSiblingDB("MovieLens").users.countDocuments();
  ')
  echo "  $node: $COUNT users"
done

echo ""
echo "=== Done ==="
echo ""
echo "Failover test:"
echo "  docker stop mongo-primary"
echo "  docker exec mongo-secondary1 mongosh --eval 'rs.status()'"
