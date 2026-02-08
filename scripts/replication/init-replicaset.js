const config = {
  _id: "RS1",
  members: [
    { _id: 0, host: "mongo-primary:27017", priority: 2 },
    { _id: 1, host: "mongo-secondary1:27017", priority: 1 },
    { _id: 2, host: "mongo-secondary2:27017", priority: 1 },
    { _id: 3, host: "mongo-secondary3:27017", priority: 1 },
    { _id: 4, host: "mongo-arbiter:27017", arbiterOnly: true }
  ]
};

print("[RS1] Initializing...");

try {
  const result = rs.initiate(config);
  if (result.ok === 1) {
    print("[RS1] OK - Election in progress...");
    sleep(10000);
    const status = rs.status();
    status.members.forEach(m => print("  " + m.name + " -> " + m.stateStr));
  }
} catch (e) {
  if (e.codeName === "AlreadyInitialized") {
    print("[RS1] Already initialized");
    const status = rs.status();
    status.members.forEach(m => print("  " + m.name + " -> " + m.stateStr));
  } else {
    throw e;
  }
}
