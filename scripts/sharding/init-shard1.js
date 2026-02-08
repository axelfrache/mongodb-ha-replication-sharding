print("[RSSHARD1] Initializing...");

const config = {
    _id: "RSSHARD1",
    members: [
        { _id: 0, host: "shard1-1:27017" },
        { _id: 1, host: "shard1-2:27017" },
        { _id: 2, host: "shard1-3:27017" }
    ]
};

try {
    rs.initiate(config);
    sleep(5000);
    rs.status().members.forEach(m => print("  " + m.name + " -> " + m.stateStr));
    print("[RSSHARD1] OK");
} catch (e) {
    if (e.codeName === "AlreadyInitialized") {
        print("[RSSHARD1] Already initialized");
    } else { throw e; }
}
