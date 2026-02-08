print("[RSSHARD2] Initializing...");

const config = {
    _id: "RSSHARD2",
    members: [
        { _id: 0, host: "shard2-1:27017" },
        { _id: 1, host: "shard2-2:27017" },
        { _id: 2, host: "shard2-3:27017" }
    ]
};

try {
    rs.initiate(config);
    sleep(5000);
    rs.status().members.forEach(m => print("  " + m.name + " -> " + m.stateStr));
    print("[RSSHARD2] OK");
} catch (e) {
    if (e.codeName === "AlreadyInitialized") {
        print("[RSSHARD2] Already initialized");
    } else { throw e; }
}
