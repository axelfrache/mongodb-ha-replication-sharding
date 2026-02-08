print("[test.test_collection] Inserting 1M docs...");

use("test");

const names = ["Marc", "Bill", "George", "Eliot", "Matt", "Trey", "Tracy", "Greg", "Steve", "Kristina", "Katie", "Jeff"];
const start = new Date();
const total = 1000000;
const batch = 10000;

for (let b = 0; b < total / batch; b++) {
    const bulk = db.test_collection.initializeUnorderedBulkOp();
    for (let i = 0; i < batch; i++) {
        bulk.insert({
            user_id: b * batch + i,
            name: names[Math.floor(Math.random() * names.length)],
            number: Math.floor(Math.random() * 10001)
        });
    }
    bulk.execute();
    if ((b + 1) * batch % 200000 === 0) {
        print("  " + ((b + 1) * batch / 1000) + "K");
    }
}

const duration = ((new Date()) - start) / 1000;
print("[test.test_collection] OK (" + duration.toFixed(1) + "s)");
print("");
print("[Distribution]");
db.test_collection.getShardDistribution();
