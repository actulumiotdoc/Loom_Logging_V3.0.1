#!/bin/bash
user=$HOME
stdDir=sqlite/db
db=sqlite/db/factory.db

sudo apt update && sudo apt -y upgrade
if [ ! -d "$stdDIr" ]; then
  mkdir -p $stdDIr
  echo "Create Sqlite Directory..."
else
  echo "Already has Sqlite Directory..."
fi

if [ ! -f "$db" ]; then
  sqlite3 "$db" "
  CREATE TABLE raw_data_sensors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    create_at DATETIME DEFAULT (datetime('now', '+7 hours')),
    ts INTEGER NOT NULL,
    total_meter REAL,
    total_a REAL,
    total_b REAL,
    nta_meter REAL,
    ntb_meter REAL,
    ota_meter REAL,
    otb_meter REAL,
    hour_meter REAL,
    speed_main REAL,
    speed_take REAL,
    sent INTEGER DEFAULT 0,
    sent_at INTEGER,
  );
  "
  echo "Create DataBase Succesfully..."
else

  echo "Already has Database..."
fi
