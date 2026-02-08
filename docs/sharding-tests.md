# Sharding Tests

## Setup

```bash
docker compose -f docker-compose.replication.yml down -v  # if running
docker compose -f docker-compose.sharding.yml up -d
./scripts/sharding/init-all.sh
```

## Test 1: Config Servers

```bash
docker exec cfg1 mongosh --eval "rs.status().members.forEach(m => print(m.name + ' -> ' + m.stateStr))"
```

Expected: RSCFG with 1 PRIMARY, 2 SECONDARY

## Test 2: Shards

```bash
docker exec shard1-1 mongosh --eval "rs.status().members.forEach(m => print(m.name + ' -> ' + m.stateStr))"
```

## Test 3: Cluster Status

```bash
docker exec mongos mongosh --eval "sh.status()"
```

Expected: 3 shards, test and MovieLens configured

## Test 4: Import MovieLens

```bash
docker exec mongos mongoimport --db MovieLens --collection movies --file /data/import/movielens_movies.json
```

Verification:
```bash
docker exec mongos mongosh --eval 'db.getSiblingDB("MovieLens").movies.countDocuments()'
```

## Test 5: Massive Insert

```bash
docker exec -i mongos mongosh < scripts/sharding/insert-data.js
```

## Test 6: Distribution

```bash
docker exec mongos mongosh --eval 'db.getSiblingDB("test").test_collection.getShardDistribution()'
```

Expected: ~33% per shard

## Test 7: Balancer

```bash
docker exec mongos mongosh --eval "sh.isBalancerRunning()"
docker exec mongos mongosh --eval "sh.getBalancerState()"
```

## Automated Script

```bash
bash scripts/sharding/test-sharding.sh
```

## Summary

| Test | Command | Expected |
|------|---------|----------|
| Config | rs.status() on cfg1 | 1 PRIMARY, 2 SECONDARY |
| Cluster | sh.status() | 3 shards active |
| Distribution | getShardDistribution() | ~33% per shard |
| Balancer | sh.isBalancerRunning() | true |
