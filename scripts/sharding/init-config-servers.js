print("[RSCFG] Initializing...");

const config = {
    _id: "RSCFG",
    configsvr: true,
    members: [
        { _id: 0, host: "cfg1:27017" },
        { _id: 1, host: "cfg2:27017" },
        { _id: 2, host: "cfg3:27017" }
    ]
};

try {
    rs.initiate(config);
    sleep(5000);
    rs.status().members.forEach(m => print("  " + m.name + " -> " + m.stateStr));
    print("[RSCFG] OK");
} catch (e) {
    if (e.codeName === "AlreadyInitialized") {
        print("[RSCFG] Already initialized");
    } else { throw e; }
}
