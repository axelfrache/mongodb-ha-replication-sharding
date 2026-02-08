#!/bin/bash
set -e

echo "[MovieLens] Importing data..."

until mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; do
  sleep 1
done

mongoimport --db MovieLens --collection movies --file /data/import/movielens_movies.json --quiet
echo "  movies: $(mongosh --quiet --eval 'use MovieLens; db.movies.countDocuments()')"

mongoimport --db MovieLens --collection users --file /data/import/movielens_users.json --quiet
echo "  users: $(mongosh --quiet --eval 'use MovieLens; db.users.countDocuments()')"

echo "[MovieLens] OK"
