# MongoDB - Replication and Sharding

MongoDB academic work: replication (ReplicaSet) and sharding via Docker.

MovieLens data: `data/movielens/`

## Architecture

### ReplicaSet RS1

| Node | Port | Role |
|------|------|------|
| mongo-primary | 27017 | PRIMARY (priority 2) |
| mongo-secondary1 | 27018 | SECONDARY |
| mongo-secondary2 | 27019 | SECONDARY |
| mongo-secondary3 | 27020 | SECONDARY |
| mongo-arbiter | 30000 | ARBITER |

### Sharding

| Component | Nodes | Ports |
|-----------|-------|-------|
| Config Servers (RSCFG) | cfg1, cfg2, cfg3 | 28017-28019 |
| Mongos | mongos | 31000 |
| RSSHARD1 | shard1-1/2/3 | 29017-29019 |
| RSSHARD2 | shard2-1/2/3 | 29020-29022 |
| RSSHARD3 | shard3-1/2/3 | 29023-29025 |

## Part 1: Replication

```bash
docker compose -f docker-compose.replication.yml up -d
docker exec -i mongo-primary mongosh < scripts/replication/init-replicaset.js
docker exec mongo-primary bash /scripts/import-data.sh
```

Verification:
```bash
docker exec mongo-primary mongosh --eval "rs.status()"
```

Failover test:
```bash
docker stop mongo-primary
docker exec mongo-secondary1 mongosh --eval "rs.status()"
docker start mongo-primary
```

## Part 2: Sharding

```bash
docker compose -f docker-compose.replication.yml down -v
docker compose -f docker-compose.sharding.yml up -d
./scripts/sharding/init-all.sh
```

Import and test:
```bash
docker exec mongos mongoimport --db MovieLens --collection movies --file /data/import/movielens_movies.json
docker exec -i mongos mongosh < scripts/sharding/insert-data.js
```

Verification:
```bash
docker exec mongos mongosh --eval 'db.getSiblingDB("test").test_collection.getShardDistribution()'
```

Expected: ~33% per shard.

## Cleanup

```bash
docker compose -f docker-compose.replication.yml down -v
docker compose -f docker-compose.sharding.yml down -v
```
