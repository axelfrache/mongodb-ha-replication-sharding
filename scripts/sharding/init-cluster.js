print("[Cluster] Adding shards...");
sh.addShard("RSSHARD1/shard1-1:27017,shard1-2:27017,shard1-3:27017");
sh.addShard("RSSHARD2/shard2-1:27017,shard2-2:27017,shard2-3:27017");
sh.addShard("RSSHARD3/shard3-1:27017,shard3-2:27017,shard3-3:27017");
print("  3 shards added");

print("[Cluster] Configuring test.test_collection...");
sh.enableSharding("test");
sh.shardCollection("test.test_collection", { "user_id": "hashed" });
print("  test.test_collection: user_id hashed");

print("[Cluster] Configuring MovieLens.movies...");
sh.enableSharding("MovieLens");
sh.shardCollection("MovieLens.movies", { "title": "hashed" });
print("  MovieLens.movies: title hashed");

print("");
print("[Cluster] OK");
print("");
print("[Shards]");
db.adminCommand({ listShards: 1 }).shards.forEach(s => print("  " + s._id + ": " + s.host));
