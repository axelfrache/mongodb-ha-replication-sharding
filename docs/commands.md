# MongoDB Commands

## Connection

```bash
mongosh --port 27017                    # Replication
mongosh --port 31000                    # Sharding (via mongos)
docker exec -it <container> mongosh     # Via container
```

## Navigation

```javascript
show dbs
use MovieLens
show collections
```

## Replication

```javascript
rs.initiate(config)         // Initialize
rs.status()                 // Status
rs.conf()                   // Configuration
rs.add("host:port")         // Add member
rs.addArb("host:port")      // Add arbiter
rs.stepDown()               // Force election
db.getMongo().setReadPref("secondary")  // Read from SECONDARY
```

## Sharding

```javascript
sh.addShard("RS/host1,host2,host3")     // Add shard
sh.enableSharding("db")                  // Enable sharding
sh.shardCollection("db.coll", {key: "hashed"})  // Shard collection
sh.status()                              // Cluster status
sh.isBalancerRunning()                   // Balancer status
db.collection.getShardDistribution()     // Distribution
```

## Data

```javascript
db.coll.insertOne({...})
db.coll.insertMany([...])
db.coll.findOne({...})
db.coll.countDocuments()
```

```bash
mongoimport --port 31000 --db MovieLens --collection movies --file data/movielens/movielens_movies.json
```

## Reference

| Action | Command |
|--------|---------|
| ReplicaSet status | rs.status() |
| Sharding status | sh.status() |
| Distribution | db.coll.getShardDistribution() |
| Balancer | sh.isBalancerRunning() |
