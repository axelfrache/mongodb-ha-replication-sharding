print("[RSSHARD3] Initializing...");

const config = {
    _id: "RSSHARD3",
    members: [
        { _id: 0, host: "shard3-1:27017" },
        { _id: 1, host: "shard3-2:27017" },
        { _id: 2, host: "shard3-3:27017" }
    ]
};

try {
    rs.initiate(config);
    sleep(5000);
    rs.status().members.forEach(m => print("  " + m.name + " -> " + m.stateStr));
    print("[RSSHARD3] OK");
} catch (e) {
    if (e.codeName === "AlreadyInitialized") {
        print("[RSSHARD3] Already initialized");
    } else { throw e; }
}
