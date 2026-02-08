# Replication Tests

## Setup

```bash
docker compose -f docker-compose.sharding.yml down -v  # if running
docker compose -f docker-compose.replication.yml up -d
docker exec -i mongo-primary mongosh < scripts/replication/init-replicaset.js
```

## Test 1: ReplicaSet Status

```bash
docker exec mongo-primary mongosh --eval "rs.status().members.forEach(m => print(m.name + ' -> ' + m.stateStr))"
```

Expected: 1 PRIMARY, 3 SECONDARY, 1 ARBITER

## Test 2: Configuration

```bash
docker exec mongo-primary mongosh --eval "rs.conf()"
```

Expected: priority 2 for PRIMARY, arbiterOnly for ARBITER

## Test 3: Data Replication

Insert:
```bash
docker exec mongo-primary mongosh --eval 'db.getSiblingDB("MovieLens").users.insertOne({name: "Test"})'
```

Read on SECONDARY:
```bash
docker exec mongo-secondary1 mongosh --eval 'db.getMongo().setReadPref("secondary"); db.getSiblingDB("MovieLens").users.findOne({name: "Test"})'
```

## Test 4: Failover

```bash
docker stop mongo-primary
sleep 15
docker exec mongo-secondary1 mongosh --eval "rs.status().members.forEach(m => print(m.name + ' -> ' + m.stateStr))"
docker start mongo-primary
```

Expected: one SECONDARY becomes PRIMARY

## Automated Script

```bash
./scripts/replication/test-replication.sh
```

## Note

Asynchronous replication via oplog. Deprecated: `rs.slaveOk()` -> `db.getMongo().setReadPref("secondary")`
